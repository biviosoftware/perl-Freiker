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
	$self->field_decl(visible => [
	    qw(
		Address.street1
		Address.city
		Address.state
		Address.zip
		Address.country
		Website.url
	    ),
	    {name => 'Address.street2', constraint => 'NONE'},
	], {constraint => 'NOT_NULL'}),
    });
}

1;
