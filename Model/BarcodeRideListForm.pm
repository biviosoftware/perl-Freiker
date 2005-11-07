# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeRideListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok_row {
    my($self) = @_;
    $self->get_list_model->get_model('Ride')->unauth_delete
	if $self->get('want_delete');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'BarcodeRideList',
	require_context => 1,
	visible => [
	    {
		name => 'want_delete',
		type => 'Boolean',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
    });
}

1;
