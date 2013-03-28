# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Export;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CSV) = b_use('ShellUtil.CSV');
my($_D) = b_use('Type.Date');
my($_T) = b_use('Type.Time');
my($_YQ) = b_use('Type.YearQuery');

sub USAGE {
    return <<'EOF';
usage: bivio Export [options] command [args..]
commands
  school_zip year -- creates zip file for school year data
EOF
}

sub school_zip {
    my($self, $year) = @_;
    $self->usage_error('missing year')
	unless $year;
    $year = b_use('Type.Year')->from_literal_or_die($year);
    my($school_year) = $self->model(SchoolYear => {
	start_date => $_D->date_from_parts(
	    1, $_YQ->START_MONTH, $year),
    });
    my($zip) = b_use('IO.Zip')->new;
    _add_to_zip($zip, _school($self), 'school.csv');
    _add_to_zip($zip, _rides($self, $school_year), 'rides.csv');
    _add_to_zip($zip, _classes($self, $school_year), 'classes.csv');
    _add_to_zip($zip, _users($self, $school_year), 'users.csv');
    my($outfile) = $self->req(qw(auth_realm owner name))
	. '-' . $_YQ->compile_short_desc($year) . '.zip';
    $outfile =~ s/\s+//g;
    $zip->write_to_file($outfile);
    $self->print('created export file: ', $outfile, "\n");
    return;
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

sub _rides {
    my($self, $school_year) = @_;
    my($user_ids) = {};
    $self->put(user_ids => $user_ids);
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
	    return 1;
	},
	'unauth_iterate_start',
	'ride_date ASC, ride_time ASC',
	{
	    club_id => $self->req('auth_id'),
	},
    );
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

    foreach my $class_id (@$class_ids) {
	$self->model('RealmUser')->do_iterate(
	    sub {
		my($realm_user) = @_;
		_add_row(
		    $self, $rows, $realm_user,
		    $info->unauth_load({
			user_id => $realm_user->get('user_id'),
		    })
			? $info
		        : (),
		    )
		    if $user_ids->{$realm_user->get('user_id')};
		return 1;
	    },
	    'unauth_iterate_start',
	    {
		realm_id => $class_id,
	    },
	);
    }
    $rows->[0]->[1] = 'school_class_id';
    return $rows;
}

1;
