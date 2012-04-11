# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideList;
use strict;
use Bivio::Base 'Model.NumberedList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
    return 0;
}

1;
