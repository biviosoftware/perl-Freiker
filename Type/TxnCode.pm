# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::TxnCode;
use strict;
use Bivio::Base 'Type.Integer';
use Bivio::Biz::Random;


sub generate_random {
    my($proto) = @_;
    return Bivio::Biz::Random->integer($proto->get_max, $proto->get_min);
}

sub get_max {
    return 9_999_999;
}

sub get_min {
    return 1_000_000;
}

1;
