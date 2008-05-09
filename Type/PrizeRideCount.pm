# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::PrizeRideCount;
use strict;
use Bivio::Base 'Type.RideCount';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_min {
    return 0;
}

1;
