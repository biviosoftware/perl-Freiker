# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Freiker;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub USAGE {
    return <<'EOF';
usage: fr-club [options] command [args..]
commands
  codes -- returns codes for current realm
  info freiker_code -- list user, club, and family info
  missing_rides freiker_code -- lists missing rides for freiker_code
EOF
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
    my($req) = $self->get_request;
    my($dates) = {@{
	$self->unauth_model('ClubRideDateList', {auth_id => $club_id})
	    ->map_rows(sub {shift->get('Ride.ride_date') => 1}),
    }};
    $req->with_realm(
	$club_id,
	sub {
	    $self->model('FreikerRideList', {
		parent_id => $user_id,
	    })->do_rows(sub {
		delete($dates->{shift->get('Ride.ride_date')});
		return 1;
	    });
	},
    );
    return [map(
	$_D->to_string($_),
	sort {$_D->compare($b, $a)} keys(%$dates),
    )];
}

sub rides {
    my($self, $user_id, $club_id, $family_id) = _args(@_);
    return $self->unauth_model(FreikerRideList => {
	parent_id => $user_id,
	auth_id => $club_id,
    })->map_rows(sub {$_D->to_string(shift->get('Ride.ride_date'))});
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

1;
