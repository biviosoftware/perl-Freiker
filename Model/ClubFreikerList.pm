# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerList;
use strict;
use Bivio::Base 'Model.FreikerList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

sub PRIZE_SELECT_LIST {
    return 'ClubPrizeSelectList';
}

1;
