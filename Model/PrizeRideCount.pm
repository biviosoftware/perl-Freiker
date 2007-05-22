# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeRideCount;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    $values->{ride_count} ||= 0;
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'prize_ride_count_t',
	columns => {
	    prize_id => ['Prize.prize_id', 'PRIMARY_KEY'],
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
	    ride_count => ['RideCount', 'NOT_NULL'],
	},
    });
}

1;
