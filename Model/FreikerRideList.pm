# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRideList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_display_name {
    my($self) = @_;
    my($uid) = $self->get_user_id;
    return $self->new_other('RealmOwner')
	->unauth_load_or_die({realm_id => $uid})
        ->get('display_name')
	. ' '
	. $self->new_other('UserFreikerCodeList')->get_display_name($uid);
}

sub get_user_id {
    return shift->get_query->get('parent_id');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['Ride.ride_date'],
        order_by => ['Ride.ride_date'],
	parent_id => [qw(Ride.user_id RealmUser.user_id)],
	auth_id => ['RealmUser.realm_id'],
	other => ['Ride.ride_upload_id'],
    });
}

1;
