# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::RideType;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => [0, 'Select'],
    BIKE => 1,
    BUS => 2,
    WALK => 3,
    OTHER => 99,
]);

sub is_continuous {
    return 0;
}

1;
