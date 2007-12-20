# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRegisterForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->internal_catch_field_constraint_error(
	club_name => sub {
	    $self->new_other('Club')->create_realm(
		$self->req('auth_user_id'),
		$self->get('club_name'),
		$self->get_model_properties('Address'),
		$self->get_model_properties('Website'),
		$self->get('club_size'),
	    );
	    return;
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
	    'Website.url',
	    {
		name => 'club_size',
		type => 'ClubSize',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

1;
