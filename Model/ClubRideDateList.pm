# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRideDateList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	date => 'Ride.ride_date',
	primary_key => ['Ride.ride_date'],
        order_by => [
	    'Ride.ride_date',
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => 'COUNT(ride_t.user_id) AS ride_count',
	    },
	],
        group_by => ['Ride.ride_date'],
	auth_id => [qw(FreikerCode.club_id)],
	other => [
	    map(+{
		name => $_,
		in_select => 0,
	    }, qw(Ride.user_id FreikerCode.freiker_code)),
	    [qw(Ride.user_id FreikerCode.user_id)],
	],
    });
}

sub is_date_ok {
    my($self, $date) = @_;
    $self->unauth_load_all({
	auth_id => $self->get_request->map_user_realms(
	    sub {shift->{'RealmUser.realm_id'}},
	    {'RealmOwner.realm_type' => Bivio::Auth::RealmType->CLUB},
	)->[0],
    }) unless $self->is_loaded;
    return $self->find_row_by_date($date) ? 1 : 0;
}

1;
