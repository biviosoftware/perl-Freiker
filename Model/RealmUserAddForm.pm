# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RealmUserAddForm;
use strict;
use Bivio::Base 'Model';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'Address.country',
		constraint => 'NONE',
	    },
	    {
		name => 'Address.zip',
		constraint => 'NONE',
	    },
	],
    });
}

1;
