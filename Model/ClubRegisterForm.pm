# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRegisterForm;
use strict;
use base 'Bivio::Biz::Model::UserRegisterForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

do not show fields if logged in.  Addre 

sub internal_create_models {
    my($self) = @_;
    my($req) = $self->get_request;
    my($realm, @rest) = $self->get('user_exists')
	? ($req->get('auth_user'), $self->new_other('User')->load_for_auth_user)
	: shift->SUPER::internal_create_models(@_);
    return $realm && !$self->internal_catch_field_constraint_error(
	club_name => sub {
	    $self->new_other('ClubAux')->create_realm(
		$self->get_model_properties('ClubAux'),
		$realm->get('realm_id'),
		$self->get('club_name'),
		$self->get_model_properties('Address'),
	    );
	},
    ) ? ($realm, @rest) : ();
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    {
		name => 'club_name',
		type => 'RealmOwner.display_name',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'Address.zip',
		type => 'USZipCode9',
		constraint => 'NOT_NULL',
	    },
	    'ClubAux.website',
	    'ClubAux.club_size',
	],
	other => [
	    {
		name => 'user_exists',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(
	user_exists => $self->get_request->get('auth_user') ? 1 : 0);
    return shift->SUPER::internal_pre_execute(@_);
}

1;
