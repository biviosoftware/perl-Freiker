# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::RideType;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    BIKE => 1,
    BUS => 2,
    WALK => 3,
    CARPOOL => 4,
    OTHER => 99,
]);

sub ROW_TAG_KEY {
    return 'DEFAULT_RIDE_TYPE';
}

sub is_continuous {
    return 0;
}

1;
