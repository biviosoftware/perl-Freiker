# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::BikeEventCount;
use strict;
use Bivio::Base 'Type.Integer';


sub get_max {
    return 100_000;
}

sub get_min {
    return 0;
}

1;
