# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRideCountList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

#TODO: not the same as  select ride_date, count(user_id) from ride_t where club_id = 100002 group \
## by ride_date order by ride_date desc; does not work with Fill Trips');
sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	date => 'Ride.ride_date',
	primary_key => [['Ride.user_id', 'RealmUser.user_id']],
	group_by => ['Ride.user_id'],
	order_by => [
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		sort_order => 0,
		select_value => 'COUNT(ride_t.ride_date) AS ride_count',
	    },
	],
	other => [
	    map(+{
		name => $_,
		in_select => 0,
	    }, qw(
	        RealmUser.role
		RealmUser.realm_id
		Ride.ride_date
	    )),
	],
	auth_id => 'RealmUser.realm_id',
    });
}

1;
