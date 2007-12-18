# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RideUpload;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REALM_ID_FIELD {
    return 'club_id';
}

sub USER_ID_FIELD {
    return 'freikometer_user_id';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'ride_upload_t',
	columns => {
            ride_upload_id => ['PrimaryId', 'PRIMARY_KEY'],
	    club_id => ['Club.club_id', 'NOT_NULL'],
	    freikometer_user_id => ['User.user_id', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
        },
    });
}

1;
