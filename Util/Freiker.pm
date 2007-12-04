# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Freiker;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');

sub USAGE {
    return <<'EOF';
usage: fr-club [options] command [args..]
commands
  info freiker_code -- list user, club, and family info
  missing_rides freiker_code -- lists missing rides for freiker_code
EOF
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
	$family_id,
	sub {
	    $self->unauth_model('FreikerRideList', {
		parent_id => $user_id,
		auth_id => $req->get('auth_id'),
	    })->do_rows(sub {
		delete($dates->{shift->get('Ride.ride_date')});
		return 1;
	    });
	},
    );
    return [reverse(sort(map($_D->to_file_name($_), keys(%$dates))))];
}

sub _args {
    my($self, $freiker_code) = @_;
    my($req) = $self->get_request;
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
    $self->usage_error($freiker_code, ': freiker code not found')
	unless $user_id;
    return ($self, $user_id, $club_id, $req->with_user($user_id, sub {
	@{$req->map_user_realms(sub {
	    my($row) = @_;
	    return $row->{'RealmOwner.realm_type'}->eq_user
		    ? $row->{'RealmUser.realm_id'} : ();
	    }, {
		'RealmUser.role' => Bivio::Auth::Role->MEMBER,
	    })},
	}),
    );
}

1;
