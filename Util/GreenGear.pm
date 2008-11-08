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
  last_week [end-date [start-date]] -- computes from start-date (-5 riding days) to end-date
EOF
}

sub last_week {
    my($self, $end, $start) = shift->name_args([
	['Date', undef, $_D->now],
	'?Date',
    ], \@_);
    my($code, $epc, $user_id) = _choose($self, _choices($self, \$start, \$end));
    $self->new_other('Freikometer')->do_all(download => {
	filename => 'green_gear',
	content => \($epc),
	content_type => 'text/plain',
    });
    $self->commit_or_rollback;
    my($res) = join(
	"\n",
	'Dates: ' . $_D->to_string($start) . ' - ' . $_D->to_string($end),
	',gg=' . $_D->to_string($_D->local_today),
	'GreenGear ' . $self->req(qw(auth_realm owner display_name)),
	$code,
    );
    if ($user_id) {
	$res .=
	    ', '
	    . $self->unauth_model(RealmOwner => {realm_id => $user_id})
		->get('display_name');
	if (my $fid = $self->model('RealmUser')
	    ->unsafe_family_id_for_freiker($user_id)
	) {
	    my($r) = $self->unauth_model(RealmOwner => {realm_id => $fid});
	    $res .= ', ' . $r->get('display_name')
		. ', ' . $self->unauth_model(
		    Email => {realm_id => $r->get('realm_id')},
		)->get('email');
	}
    }
    return $res;
}

sub _choices {
    my($self, $start, $end) = @_;
    $$end = _search_dow($$end, 'Friday', -1)
	if $_DT->english_day_of_week($$end) =~ /Sat|Sun/;
    $$start ||= _search_dow($$end, 'Monday', -1);
    my($max);
    return Bivio::SQL::Connection->map_execute(sub {
        my($row) = @_;
	unless (defined($max)) {
	    $max = $row->[1];
	    _trace('max=', $max) if $_TRACE;
	}
	return $row->[1] == $max ? $row->[0] : ();
    },
        qq{SELECT ride_t.user_id, count(ride_date)
	    FROM ride_t, realm_user_t
	    WHERE realm_user_t.user_id = ride_t.user_id
	    AND realm_user_t.realm_id = ?
	    AND ride_date BETWEEN $_DT_SQL AND $_DT_SQL
	    GROUP BY ride_t.user_id
	    ORDER BY count(ride_date) desc},
        [$self->req('auth_id'), $$start, $$end],
    );
}

sub _choose {
    my($self, $choices) = @_;
    Bivio::Die->die('no choices?')
        unless @$choices;
    _trace($choices) if $_TRACE;
    my($id) = $choices->[Bivio::Biz::Random->integer(scalar(@$choices))];
    my($epc, $code);
    $self->model('FreikerCode')->do_iterate(
	sub {
	    ($epc, $code) = shift->get(qw(epc freiker_code));
	    return 0;
	},
	'modified_date_time desc',
	{user_id => $id},
    );
    return ($code, $epc, $id);
}

sub _search_dow {
    my($value, $dow, $inc) = @_;
    $value = $_DT->add_days($value, $inc)
	while $_DT->english_day_of_week($value) ne $dow;
    return $value;
}

1;
