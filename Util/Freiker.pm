# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Freiker;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_FREIKER) = b_use('Auth.Role')->FREIKER;
my($_CLUB) = b_use('Auth.RealmType')->CLUB;
my($_RECIPROCAL_RIGHTS) = b_use('Type.RealmDAG')->RECIPROCAL_RIGHTS;
my($_DT) = b_use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: fr-club [options] command [args..]
commands
  audit_clubs - verify user_id is not bound to more than one club
  codes -- returns codes for current realm
  info freiker_code -- list user, club, and family info
  missing_rides freiker_code -- lists missing rides for freiker_code
EOF
}

sub audit_clubs {
    my($self) = @_;
    my($req) = $self->req;
    my($clubs) = _clubs($req);
    return
	if @$clubs <= 1;
    my($curr_club, $curr_dt) = @{shift(@$clubs)}
	{qw(RealmUser.realm_id RealmUser.creation_date_time)};
    my($old_uid) = $req->get('auth_user')->get(qw(realm_id));
    my($fid) = $self->model('RealmUser')
	->unsafe_family_id_for_freiker($old_uid);
    my($user_values) = _compute_user_values($self, $old_uid);
    foreach my $club (@$clubs) {
	my($prev_club) = $club->{'RealmUser.realm_id'};
	$req->with_realm($prev_club, sub {
	    my($switch_date, $ru, $rides) = _compute_switch_date($self, $old_uid);
	    my($new_uid) = _update_user($self, $user_values, $switch_date);
	    _update_realm_user($self, $ru, $new_uid, $fid);
	    _update_school_classes($self, $old_uid, $new_uid);
	    _update_freiker_info($self, $old_uid, $new_uid);
	    _create_realm_dag($self, $old_uid, $new_uid);
	    _update_freiker_code($self, $old_uid, $new_uid);
	    _update_rides($self, $old_uid, $new_uid, $rides, $switch_date);
	    _update_prize($self, $old_uid, $new_uid, $curr_dt);
	});
    }
    return;
}

sub codes {
    my($self) = @_;
    return $self->model('UserFreikerCodeList')
	->get_codes($self->req('auth_id'));
}

sub info {
    my($self, @ids) = _args(@_);
    return join('', map(
	$self->new_other('RealmAdmin')->info(
	    $self->unauth_model(RealmOwner => {realm_id => $_})),
	@ids,
    ));
}

sub missing_rides {
    my($self, $user_id, $club_id, $family_id) = _args(@_);
    my($dates);
    $self->req->with_realm(
	$club_id,
	sub {
	    $dates = {@{
		$self->model('ClubRideDateList', {})
		    ->map_rows(sub {shift->get('Ride.ride_date') => 1}),
	    }};
	    $self->model('FreikerRideList', {
		parent_id => $user_id,
	    })->do_rows(sub {
		delete($dates->{shift->get('Ride.ride_date')});
		return 1;
	    });
	    return;
	},
    );
    return [map(
	$_D->to_string($_),
	sort {$_D->compare($b, $a)} keys(%$dates),
    )];
}

sub rides {
    my($self, $user_id, $club_id, $family_id) = _args(@_);
    return $self->req->with_realm($club_id, sub {
	return $self->model(
	    'FreikerRideList',
	    {parent_id => $user_id},
	)->map_rows(sub {$_D->to_string(shift->get('Ride.ride_date'))});
    });
}

sub _args {
    my($self, $freiker_code) = @_;
    my($req) = $self->get_request;
    my($club_id, $user_id) = $self->unauth_model('FreikerCode', {
	freiker_code => $freiker_code,
    })->get(qw(club_id user_id));
    $self->usage_error($freiker_code, ': freiker code not found')
	unless $user_id;
    return ($self, $user_id, $club_id,
	    $self->model('RealmUser')->unsafe_family_id_for_freiker($user_id));
}

sub _clubs {
    my($req) = @_;
    return [sort({
	$_DT->compare(
	    $b->{'RealmOwner.creation_date_time'},
	    $a->{'RealmOwner.creation_date_time'},
	);
    } @{$req->map_user_realms(
	    sub {+{%{shift(@_)}}},
	    {
		roles => $_FREIKER,
		'RealmOwner.realm_type' => $_CLUB,
	    },
	),
    })];
}

sub _compute_switch_date {
    my($self, $old_uid) = @_;
    my($ru) = $self->model('RealmUser')->load({user_id => $old_uid});
    my($rides) = $self->model('FreikerClubRideList')->load_all({
	parent_id => $old_uid,
    });
    return (
	$rides->get_result_set_size
	    ? $rides->set_cursor_or_die(0)->get('Ride.ride_date')
	    : $ru->get('creation_date_time'),
	$ru,
	$rides,
    );
}

sub _compute_user_values {
    my($self, $old_uid) = @_;
    my($u) = $self->model('User')->unauth_load_or_die({user_id => $old_uid});
    my($user_values) = $u->get_shallow_copy;
    delete($user_values->{user_id});
    $user_values->{last_name} =~ s/\s*\($_D->TO_STRING_REGEX\)//
	if $user_values->{last_name};
    return $user_values;
}

sub _create_realm_dag {
    my($self, $old_uid, $new_uid) = @_;
    $self->model('RealmDAG')->create({
	parent_id => $old_uid,
	child_id => $new_uid,
	realm_dag_type => $_RECIPROCAL_RIGHTS,
    });
    return;
}

sub _update_freiker_code {
    my($self, $old_uid, $new_uid) = @_;
    $self->model('FreikerCode')->do_iterate(
	sub {
	    shift->update({user_id => $new_uid});
	    return 1;
	},
	'freiker_code',
	{user_id => $old_uid},
    );
    return;
}

sub _update_freiker_info {
    my($self, $old_uid, $new_uid) = @_;
    $self->model('FreikerInfo')->create({
	%{
	    $self->model('FreikerInfo')
		->unauth_load_or_die({user_id => $old_uid})
		->get_shallow_copy
	},
	user_id => $new_uid,
	modified_date_time => undef,
    });
    $self->model('Address')->create({
	%{
	    $self->model('Address')
		->unauth_load_or_die({realm_id => $old_uid})
		->get_shallow_copy
	},
	realm_id => $new_uid,
    });
    return;
}

sub _update_prize {
    my($self, $old_uid, $new_uid, $curr_dt) = @_;
    foreach my $model (qw(PrizeCoupon PrizeReceipt)) {
	$self->model($model)->do_iterate(
	    sub {
		my($it) = @_;
		$it->update({user_id => $new_uid})
		    if $_DT->compare($it->get('creation_date_time'), $curr_dt) < 0;
		return 1;
	    },
	    'unauth_iterate_start',
	    'creation_date_time',
	    {user_id => $old_uid},
	);
    }
    return;
}

sub _update_realm_user {
    my($self, $ru, $new_uid, $fid) = @_;
    my($v) = $ru->get_shallow_copy;
    $ru->delete;
    $ru->create({%$v, user_id => $new_uid});
    $ru->create({
	%$v,
	realm_id => $fid,
	user_id => $new_uid,
	role => $_FREIKER,
    }) if $fid;
    return;
}

sub _update_rides {
    my($self, $old_uid, $new_uid, $rides, $switch_date) = @_;
    $rides->do_rows(sub {
	my($r) = shift->get_model('Ride');
	my($v) = $r->get_shallow_copy;
	$r->delete;
	$r->create({
	    %$v,
	    user_id => $new_uid,
	});
	return 1;
    });
    # Only works the first time, that is, all manual rides are copied
    # to the most recent school.  Too complicated to bracket the dates,
    # and not likely to happen after first release.
    $self->model('Ride')->do_iterate(
	sub {
	    my($it) = @_;
	    if ($_DT->compare($it->get('ride_date'), $switch_date) <= 0) {
		my($v) = $it->get_shallow_copy;
		$it->delete;
		$it->create({%$v, user_id => $new_uid});
	    }
	    return 1;
	},
	'unauth_iterate_start',
	'ride_date',
	{user_id => $old_uid, ride_upload_id => undef},
    );
    return;
}

sub _update_school_classes {
    my($self, $old_uid, $new_uid) = @_;
    return;
}

sub _update_user {
    my($self, $user_values, $switch_date) = @_;
    return (
	$self->model('User')->create_realm(
	    {
		%{$user_values},
		last_name =>
		    ($user_values->{last_name} ? ($user_values->{last_name} . ' ')
			 : '')
		    . '(' . $_D->to_string($switch_date) . ')',
	    },
	    {},
	),
    )[0]->get('user_id');
}

1;
