# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerNearDateList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => [['Ride.user_id', 'RealmUser.user_id']],
	want_select_distinct => 1,
	date => {
	    name => 'Ride.ride_date',
	    in_select => 0,
	},
	order_by => [
	    'Ride.user_id',
	],
	other => [
	    [{
		name => 'RealmUser.role',
		in_select => 0,
	    }, ['FREIKER']],
	],
	auth_id => {
	    name => 'RealmUser.realm_id',
	    in_select => 0,
	},
    });
}

1;
