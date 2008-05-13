# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubPrizeList;
use strict;
use Bivio::Base 'Model.AvailablePrizeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	order_by => [
	    'PrizeRideCount.ride_count',
	],
	other => [
	    [qw(Prize.prize_id PrizeRideCount.prize_id)],
	],
        auth_id => 'PrizeRideCount.realm_id'
    });
}

1;
