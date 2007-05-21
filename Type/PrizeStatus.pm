# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::PrizeStatus;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile([
    UNAPPROVED => [1],
    AVAILABLE => [2],
    REJECTED => [3],
    OBSOLETE => [4],
]);

1;
