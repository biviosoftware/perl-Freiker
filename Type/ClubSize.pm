# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::ClubSize;
use strict;
use base 'Bivio::Type::Integer';


sub get_min {
    return 1;
}

sub get_max {
    return 100000;
}

1;
