# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::UserRegisterForm;
use strict;
use Bivio::Base 'Model';

my($_FCF) = b_use('Model.FreikerCodeForm');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('Address.country' => 'US');
    return;
}

sub internal_create_models {
    my($self) = @_;
    my($realm, @rest) = shift->SUPER::internal_create_models(@_);
    $self->new_other('Address')->create({
	%{$self->get_model_properties('Address')},
	realm_id => $realm->get('realm_id'),
    }) if $realm;
    return ($realm, @rest);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Address.street1',
	    'Address.street2',
	    'Address.city',
	    'Address.state',
	    $self->field_decl(
		[qw(Address.zip Address.country)],
		{constraint => 'NOT_NULL'},
	    ),
	],
    });
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    $_FCF->validate_address($self)
	if $self->unsafe_get('Address.zip')
	&& $self->unsafe_get('Address.country');
    return;
}

1;
