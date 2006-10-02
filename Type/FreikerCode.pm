# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::FreikerCode;
use strict;
use base 'Bivio::Type::Integer';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_min {
    return 1000;
}

sub get_max {
    return 0xffff;
}

1;
