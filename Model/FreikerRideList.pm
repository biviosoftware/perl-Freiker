# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRideList;
use strict;
use base 'Freiker::Model::YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_display_name {
    my($self) = @_;
    return $self->new_other('RealmOwner')->unauth_load_or_die({
	realm_id => $self->set_cursor_or_not_found(0)->get('Ride.realm_id'),
    })->get('display_name')
    . ' (' . $self->get('Ride.freiker_code') . ')';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['Ride.ride_date'],
        order_by => ['Ride.ride_date'],
	parent_id => [qw(Ride.realm_id RealmUser.user_id)],
	other => ['Ride.freiker_code'],
	auth_id => ['RealmUser.realm_id'],
    });
}

1;
