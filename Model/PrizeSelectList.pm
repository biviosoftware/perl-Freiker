# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeSelectList;
use strict;
use Bivio::Base 'Model.ClubPrizeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
#die;    
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	parent_id => 'PrizeRideCount.realm_id',
	order_by => [
	    # Force first sort to be this
	    'Prize.name',
	    'PrizeRideCount.ride_count',
	],
	other => [
	    [qw(Prize.prize_id PrizeRideCount.prize_id)],
	],
    });
}

1;
