# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeRideList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['Ride.ride_date'],
	order_by => ['Ride.ride_date'],
	parent_id => ['RealmOwner.name'],
	other => [
	    [qw(Ride.user_id RealmOwner.realm_id RealmUser.user_id)],
	],
	where => [
	    'realm_user_t.role = ', Bivio::Auth::Role->FREIKER->as_sql_param,
        ],
	auth_id => 'RealmUser.realm_id',
    });
}

1;
