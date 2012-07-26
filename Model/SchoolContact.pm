# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolContact;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'school_contact_t',
	columns => {
	    club_id => ['Club.club_id', 'PRIMARY_KEY'],
	    email => ['Email', 'NOT_NULL'],
	    display_name => ['DisplayName', 'NOT_NULL'],
	},
	auth_id => 'club_id',
    });
}

1;
