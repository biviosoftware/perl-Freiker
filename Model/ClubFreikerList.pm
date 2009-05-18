# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerList;
use strict;
use Bivio::Base 'Model.FreikerList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
    return 10_000;
}

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

sub PRIZE_SELECT_LIST {
    return 'ClubPrizeSelectList';
}

1;
