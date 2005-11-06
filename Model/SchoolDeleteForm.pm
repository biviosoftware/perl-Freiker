# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolDeleteForm;
use strict;
use base 'Bivio::Biz::FormModel';
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($a) = $self->new_other('Address');
    return unless $a->unauth_load({
	zip => $self->get('Address.zip'),
    });
    Freiker::Test->delete_school($a->get('realm_id'), $self->get_request);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'Address.zip',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

1;
