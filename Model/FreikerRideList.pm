# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRideList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Bivio.Die');
my($_FREIKER) = b_use('Auth.Role')->FREIKER;

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
	other => [
	    'Ride.ride_upload_id',
	    'Ride.ride_type',
	    ['RealmUser.role' => [$_FREIKER]],
	],
    });
}

sub internal_prepare_statement {
    my($self) = @_;
    $_D->throw(MODEL_NOT_FOUND => {
	entity => $self->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $self->get_user_id}),
	realm => $self->req('auth_realm'),
	message => 'not a member of this school or family',
    }) unless $self->new_other('RealmUser')->unsafe_load({
	user_id => $self->get_user_id,
	role => $_FREIKER,
    });
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
