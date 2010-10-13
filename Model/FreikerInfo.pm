# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerInfo;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REALM_ID_FIELD {
    return 'user_id';
}

sub USER_ID_FIELD {
    return undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'freiker_info_t',
	columns => {
	    user_id => ['User.user_id', 'PRIMARY_KEY'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
	    distance_kilometers => ['Miles', 'NONE'],
	},
    });
}

1;
