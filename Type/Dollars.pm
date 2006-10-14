# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::Dollars;
use strict;
use base 'Bivio::Type::Amount';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub can_be_negative {
    return 0;
}

sub can_be_zero {
    return 0;
}

sub get_decimals {
    return 0;
}

1;
