# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::GreenGear;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_DT_SQL) = $_DT->to_sql_value('?');
my($_EPC) = __PACKAGE__->use('Type.EPC');
my($_D) = __PACKAGE__->use('Type.Date');
our($_TRACE);

sub USAGE {
    return <<'EOF';
usage: fr-greengear [options] command [args..]
commands
  last_week -- computes for current realm
EOF
}

sub last_week {
    my($self) = @_;
    my($winner) = _choose($self, _choices($self));
    return [
	$winner->as_string
	    . ','
	    . $winner->get('freiker_code')
	    .',gg='
	    . $_D->to_string($_D->local_today),
	$self->new_other('Freikometer')->do_all(download => {
	    filename => 'green_gear',
	    content => \($winner->as_string),
	    content_type => 'text/plain',
	}),
	$self->commit_or_rollback,
	_info($self, $winner->get('freiker_code')),
    ];
}

sub _choices {
    my($self) = @_;
    my($start) = _search_dow(
	_search_dow($_DT->local_end_of_today, 'Friday', -1),
	'Sunday',
	-1,
    );
    my($max);
    _trace($_DT->to_string($start)) if $_TRACE;
    return Bivio::SQL::Connection->map_execute(sub {
        my($row) = @_;
	unless (defined($max)) {
	    $max = $row->[1];
	    _trace('max=', $max) if $_TRACE;
	}
	return $row->[1] == $max ? $row->[0] : ();
    },
        qq{SELECT ride_t.freiker_code, count(ride_date)
	    FROM ride_t, freiker_code_t
	    WHERE freiker_code_t.freiker_code = ride_t.freiker_code
	    AND freiker_code_t.club_id = ?
	    AND ride_date BETWEEN $_DT_SQL AND $_DT_SQL
	    GROUP BY ride_t.freiker_code
	    ORDER BY count(ride_date) desc},
        [$self->req('auth_id'), $start, _search_dow($start, 'Saturday', +1)],
    );
}

sub _choose {
    my($self, $choices) = @_;
    Bivio::Die->die('no choices?')
        unless @$choices;
    _trace($choices) if $_TRACE;
    return $_EPC->new(
	$self->model('Address')->load->get('zip'),
	$choices->[Bivio::Biz::Random->integer(scalar(@$choices))],
    );
}

sub _info {
    my($self, $freiker_code) = @_;
    my($club_id) = $self->model('FreikerCode', {
	freiker_code => $freiker_code,
    })->get('club_id');
    my($user_id);
    $self->model('Ride')->do_iterate(sub {
	$user_id = shift->get('realm_id');
	return 0;
    }, unauth_iterate_start => 'ride_date', {
	freiker_code => $freiker_code,
    });
    return $self->model(RealmOwner => {realm_id => $user_id})->get('realm_type')->eq_club ? ()
	: $self->new_other('Freiker')->info($freiker_code);
}

sub _search_dow {
    my($value, $dow, $inc) = @_;
    $value = $_DT->add_days($value,$inc)
	while $_DT->english_day_of_week($value) ne $dow;
    return $value;
}

1;
