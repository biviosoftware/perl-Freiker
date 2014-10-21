# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerClubRideList;
use strict;
use Bivio::Base 'Model.FreikerRideList';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    [qw(RealmUser.realm_id Ride.club_id)],
	],
    });
}

1;
