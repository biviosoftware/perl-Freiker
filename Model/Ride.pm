# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Ride;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_EPC) = __PACKAGE__->use('Type.EPC');
my($_NO_TIME) = __PACKAGE__->use('Type.Time')->time_from_parts(0, 0, 0);

sub REALM_ID_FIELD {
    return 'user_id';
}

sub USER_ID_FIELD {
    return undef;
}

sub create {
    my($self, $values) = @_;
    $values->{ride_time} ||= $_NO_TIME;
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'ride_t',
	columns => {
	    user_id => ['User.user_id', 'PRIMARY_KEY'],
            ride_date => ['Date', 'PRIMARY_KEY'],
	    ride_time => ['Time', 'NOT_NULL'],
	    ride_upload_id => ['RideUpload.ride_upload_id', 'NOT_NULL'],
        },
    });
}

1;
