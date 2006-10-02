# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRegisterForm;
use strict;
use base 'Bivio::Biz::Model::UserCreateForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_create_models {
    my($self) = @_;
    my($realm, @rest) = shift->SUPER::internal_create_models(@_);
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
	    },
	    {
		name => 'Address.zip',
		type => 'USZipCode9',
		constraint => 'NOT_NULL',
	    },
	    'ClubAux.website',
	    'ClubAux.club_size',
	],
    });
}

1;
