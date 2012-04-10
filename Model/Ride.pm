# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Ride;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NO_TIME) = b_use('Type.Time')->time_from_parts(0, 0, 0);
my($_C) = b_use('SQL.Connection');
my($_RT) = b_use('Type.RideType');

sub NO_TIME {
    return $_NO_TIME;
}

sub REALM_ID_FIELD {
    return 'user_id';
}

sub USER_ID_FIELD {
    return undef;
}

sub count_all {
    my($self) = @_;
    return $_C->execute_one_row('SELECT COUNT(*) FROM ride_t')->[0];
}

sub create {
    my($self, $values) = @_;
    $values->{ride_time} ||= $_NO_TIME;
    $values->{ride_type} ||= $_RT->BIKE;
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'ride_t',
	columns => {
	    user_id => ['User.user_id', 'PRIMARY_KEY'],
	    club_id => ['Club.club_id', 'NOT_NULL'],
            ride_date => ['Date', 'PRIMARY_KEY'],
	    ride_time => ['Time', 'NOT_NULL'],
	    ride_upload_id => ['RideUpload.ride_upload_id', 'NONE'],
	    ride_type => ['RideType', 'NOT_NULL'],
        },
    });
}

1;
