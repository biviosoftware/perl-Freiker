# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AllCodeRideList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	order_by => [qw(
	    FreikerCode.freiker_code
	    Ride.ride_date
	)],
	primary_key => [qw(
	    FreikerCode.freiker_code
	    Ride.ride_date
	)],
	other => [
	    [
		{
		    name => 'Ride.user_id',
		    in_select => 0,
		},
		'FreikerCode.user_id',
	    ],
	],
        auth_id => [
	    {
		name => 'Ride.club_id',
		in_select => 0,
	    },
	    'FreikerCode.club_id',
	]
    });
}

1;
