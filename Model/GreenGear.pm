# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GreenGear;
use strict;
use Bivio::Base 'Model.RealmBase';


sub REALM_ID_FIELD {
    return 'club_id';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'green_gear_t',
	columns => {
	    green_gear_id => ['PrimaryId', 'PRIMARY_KEY'],
            begin_date => ['Date', 'NOT_NULL'],
	    end_date => ['Date', 'NOT_NULL'],
	    must_be_registered => ['Boolean', 'NOT_NULL'],
	    must_be_unique => ['Boolean', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
	    user_id => ['User.user_id', 'NOT_NULL'],
        },
    });
}

1;
