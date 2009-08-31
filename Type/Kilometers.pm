# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::Kilometers;
use strict;
use Bivio::Base 'Type.Number';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub can_be_negative {
    return 0;
}

sub can_be_zero {
    return 0;
}

sub from_miles {
    my($proto, $miles) = @_;
    return $proto->round($miles * 1.609344);
}

sub get_decimals {
    return 1;
}

sub get_max {
    return 99.0;
}

sub get_min {
    return 0.5;
}

sub get_precision {
    return 3;
}

sub get_width {
    return 5;
}

sub to_miles {
    my($proto, $km) = @_;
    return $proto->round($km / 1.609344);
}

1;
