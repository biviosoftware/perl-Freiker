# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AllClubRideDateList;
use strict;
use Bivio::Base 'Model.ClubRideDateList';

my($_D) = __PACKAGE__->use('Type.Date');

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{auth_id});
    return $self->merge_initialize_info($info, {
        version => 1,
	primary_key => ['RealmOwner.name', 'Ride.ride_date'],
        group_by => ['RealmOwner.name', 'RealmOwner.display_name'],
	other => [
	    [{
		name => 'Ride.club_id',
		in_select => 0,
	    }, 'RealmOwner.realm_id'],
	    'RealmOwner.display_name',
	    'RealmOwner.name',
	],
	order_by => [
	    {
		name => 'RealmOwner.display_name',
		sort_order => 0,
	    },
	],
    });
}

1;
