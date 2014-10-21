# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Export;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_CSV) = b_use('ShellUtil.CSV');
my($_D) = b_use('Type.Date');
my($_T) = b_use('Type.Time');
my($_YQ) = b_use('Type.YearQuery');

sub USAGE {
    return <<'EOF';
usage: bivio Export [options] command [args..]
commands
  school_year year -- creates a zip file with all schools for the school year
  school_zip year -- creates zip file for school year data
EOF
}

sub school_year {
    my($self, $year) = @_;
    $year = _parse_year($self, $year);
    my($school_year) = $self->model('SchoolYear');
    my($file_names) = [];
    $self->model('Club')->do_iterate(
	sub {
	    my($school) = @_;
	    return 1
		unless $school_year->unauth_load({
		    club_id => $school->get('club_id'),
		    start_date => $_D->date_from_parts(
			1, $_YQ->START_MONTH, $year),
		});
	    my($file_name) = $self->req->with_realm(
		$school->get('club_id'),
		sub {
		    return $self->school_zip($year);
		});

	    if ($self->get('ride_count') && $self->get('user_count')) {
		push(@$file_names, $file_name);
	    }
	    else {
		$self->print(
		    'no rides or users, removing: ', $file_name, "\n");
		unlink($file_name);
	    }
	    return 1;
	},
	'unauth_iterate_start',
    );
    my($zip) = b_use('IO.Zip')->new;

    foreach my $file (@$file_names) {
	$zip->add_file($file, $file);
    }
    my($outfile) = _outfile($self, 'school_year', $year);
    $zip->write_to_file($outfile);

    foreach my $file (@$file_names) {
	unlink($file);
    }
    $self->print('created export file: ', $outfile, "\n");
    return $outfile;
}

sub school_zip {
    my($self, $year) = @_;
    $year = _parse_year($self, $year);
    my($school_year) = $self->model(SchoolYear => {
	start_date => $_D->date_from_parts(
	    1, $_YQ->START_MONTH, $year),
    });
    my($zip) = b_use('IO.Zip')->new;
    _add_to_zip($zip, _school($self), 'school.csv');
    _add_to_zip($zip, _rides($self, $school_year), 'rides.csv');
    _add_to_zip($zip, _classes($self, $school_year), 'classes.csv');
    _add_to_zip($zip, _users($self, $school_year), 'users.csv');
    my($outfile) = _outfile(
	$self, $self->req(qw(auth_realm owner name)), $year);
    $zip->write_to_file($outfile);
    $self->print('created export file: ', $outfile, "\n");
    return $outfile;
}

sub _add_row {
    my($self, $rows, $m1, $m2) = @_;
    push(@$rows, [
	map({
	    my($v) = $m1->unsafe_get($_)
		|| ($m2 ? $m2->unsafe_get($_) : undef);
	    ref($v)
		? $v->get_short_desc
		: $v;
	} @{$rows->[0]}),
    ]);
    return $rows;
}

sub _add_to_zip {
    my($zip, $rows, $name) = @_;
    $zip->add_string($_CSV->from_rows($rows), $name);
    return;
}

sub _classes {
    my($self, $school_year) = @_;
    my($class_ids) = [];
    $self->put(class_ids => $class_ids);
    my($rows) = [
	[qw(school_class_id school_grade)],
    ];
    $self->model('SchoolClass')->do_iterate(
	sub {
	    my($class) = @_;
	    push(@$class_ids, $class->get('school_class_id'));
	    _add_row($self, $rows, $class);
	    return 1;
	},
	'unauth_iterate_start',
	{
	    club_id => $self->req('auth_id'),
	},
    );
    return $rows;
}

sub _outfile {
    my($self, $name, $year) = @_;
    my($res) = $name . '-' . $_YQ->compile_short_desc($year) . '.zip';
    $res =~ s/\s+//g;
    return $res;
}

sub _parse_year {
    my($self, $year) = @_;
    $self->usage_error('missing year')
	unless $year;
    return b_use('Type.Year')->from_literal_or_die($year);
}

sub _rides {
    my($self, $school_year) = @_;
    my($user_ids) = {};
    $self->put(user_ids => $user_ids);
    my($ride_count) = 0;
    my($rows) = [
	[qw(user_id ride_date ride_time ride_type)],
    ];
    my($start) = $school_year->get('start_date');
    my($end) = $_D->add_months($start, 10);
    $self->model('Ride')->do_iterate(
	sub {
	    my($ride) = @_;
	    return 1
		unless $_D->is_greater_than_or_equals(
		    $ride->get('ride_date'), $start)
		    && $_D->is_less_than_or_equals(
			$ride->get('ride_date'), $end);
	    $user_ids->{$ride->get('user_id')} = 1;
	    _add_row($self, $rows, $ride);
	    $ride_count++;
	    return 1;
	},
	'unauth_iterate_start',
	'ride_date ASC, ride_time ASC',
	{
	    club_id => $self->req('auth_id'),
	},
    );
    $self->put(ride_count => $ride_count);
    foreach my $row (@$rows) {
	next if $row->[1] eq 'ride_date';
	$row->[1] = $_D->to_string($row->[1]);
	$row->[2] = $_T->to_string($row->[2]);
    }
    return $rows;
}

sub _school {
    my($self) = @_;
    return _add_row(
	$self,
	[
	    [qw(display_name street1 street2 city state zip country)],
	],
	$self->model('RealmOwner', {}),
	$self->model('Address', {})
    );
}

sub _users {
    my($self, $school_year) = @_;
    my($user_ids) = $self->get('user_ids');
    my($class_ids) = $self->get('class_ids');
    my($rows) = [
	[qw(user_id realm_id distance_kilometers)],
    ];
    my($info) = $self->model('FreikerInfo');
    my($user_count) = 0;

    foreach my $class_id (@$class_ids) {
	$self->model('RealmUser')->do_iterate(
	    sub {
		my($realm_user) = @_;
		if ($user_ids->{$realm_user->get('user_id')}) {
		    _add_row(
			$self, $rows, $realm_user,
			$info->unauth_load({
			    user_id => $realm_user->get('user_id'),
			})
			    ? $info
			    : (),
		    );
		    $user_count++;
		}
		return 1;
	    },
	    'unauth_iterate_start',
	    {
		realm_id => $class_id,
	    },
	);
    }
    $self->put(user_count => $user_count);
    $rows->[0]->[1] = 'school_class_id';
    return $rows;
}

1;
