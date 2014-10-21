# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::RideCount;
use strict;
use Bivio::Base 'Type.Integer';


sub get_min {
    return 1;
}

sub get_max {
    return 1000;
}

1;
