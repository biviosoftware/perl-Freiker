# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::UserRegisterForm;
use strict;
use base 'Bivio::Biz::Model::UserRegisterForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
	    'Address.zip',
	],
    });
}

1;
