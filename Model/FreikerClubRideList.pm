# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerClubRideList;
use strict;
use Bivio::Base 'Model.FreikerRideList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    [qw(Ride.ride_upload_id RideUpload.ride_upload_id)],
	    [qw(RealmUser.realm_id RideUpload.club_id)],
	],
    });
}

1;
