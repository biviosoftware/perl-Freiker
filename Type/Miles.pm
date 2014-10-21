# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::Miles;
use strict;
use Bivio::Base 'Type.Kilometers';


sub can_be_negative {
    return 0;
}

sub can_be_zero {
    return 0;
}

sub get_max {
    my($proto) = @_;
    return $proto->to_miles($proto->SUPER::get_max);
}

sub get_min {
    my($proto) = @_;
    return $proto->to_miles($proto->SUPER::get_min);
}

1;
