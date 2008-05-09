# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubPrizeSelectList;
use strict;
use Bivio::Base 'Model.PrizeSelectList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub FREIKER_LIST {
    return 'ClubFreikerList';
}

1;
