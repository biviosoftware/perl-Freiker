# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRegisterForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->internal_catch_field_constraint_error(
	club_name => sub {
	    $self->new_other('ClubAux')->create_realm(
		$self->get_model_properties('ClubAux'),
		$self->get_request->get('auth_user_id'),
		$self->get('club_name'),
		$self->get_model_properties('Address'),
	    );
	},
    );
    return;
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
    });
}

1;
