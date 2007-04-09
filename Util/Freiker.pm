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
  missing_rides freiker_code -- lists missing rides for freiker_code
EOF
}

sub missing_rides {
    my($self, $freiker_code) = @_;
    my($req) = $self->get_request;
    my($club_id) = $self->model('FreikerCode', {
	freiker_code => $freiker_code,
    })->get('club_id');
    my($uid);
    $self->model('Ride')->do_iterate(sub {
	$uid = shift->get('realm_id');
	return 0;
    }, unauth_iterate_start => 'ride_date', {
	freiker_code => $freiker_code,
    });
    $self->usage_error($freiker_code, ': freiker code not found')
	unless $uid;
    my($dates) = {@{
	$self->model('ClubRideDateList', {parent_id => $club_id})
	    ->map_rows(sub {shift->get('Ride.ride_date') => 1}),
    }};
    $req->with_realm(
	$req->with_user($uid, sub {
	    @{$req->map_user_realms(sub {
		my($row) = @_;
	        return $row->{'RealmOwner.realm_type'}->eq_user
		    ? $row->{'RealmUser.realm_id'} : ();
	    }, {
		'RealmUser.role' => Bivio::Auth::Role->MEMBER,
	    })},
	}),
	sub {
	    $self->model('FreikerRideList', {
		parent_id => $uid,
		auth_id => $req->get('auth_id'),
	    })->do_rows(sub {
		delete($dates->{shift->get('Ride.ride_date')});
		return 1;
	    });
	},
    );
    return [reverse(sort(map($_D->to_file_name($_), keys(%$dates))))];
}

1;
