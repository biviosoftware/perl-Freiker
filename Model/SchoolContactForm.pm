# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolContactForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    my($res) = shift->SUPER::execute_empty(@_);
    $self->load_from_model_properties('SchoolContact');
    return $res;
}

sub execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::execute_ok(@_);
    $self->update_model_properties('SchoolContact');
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [qw(
	    SchoolContact.display_name
	    SchoolContact.email
	)],
    });
}

1;
