# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::OrganizationInfoForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('Address.country' => 'US');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    $self->field_decl([qw(
		Address.street1
		Address.city
		Address.state
		Address.zip
		Address.country
		Website.url
	    )], undef, 'NOT_NULL'),
	    {name => 'Address.street2', constraint => 'NONE'},
	],
    });
}

1;
