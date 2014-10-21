# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRideList;
use strict;
use Bivio::Base 'Model.YearBaseList';

my($_D) = b_use('Bivio.Die');
my($_FREIKER) = b_use('Auth.Role')->FREIKER;

sub assert_access {
    my($self, $model, $user_id) = @_;
    $model ||= $self;
    $user_id ||= $model->get_user_id;
    $_D->throw(MODEL_NOT_FOUND => {
	entity => $model->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $user_id}),
	realm => $model->req('auth_realm'),
	message => 'not a member of this school or family',
    }) unless $model->new_other('RealmUser')->unsafe_load({
	user_id => $user_id,
	role => $_FREIKER,
    });
    return;
}

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
    $self->assert_access;
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
