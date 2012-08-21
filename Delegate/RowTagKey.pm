# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	CLUB_SIZE => [100, 'ClubSize'],
	UNUSED_101 => [101],
	NEED_ACCEPT_TERMS => [102, 'BooleanFalseDefault'],
	HAS_GRADUATED => [103, 'BooleanFalseDefault'],
	ALLOW_TAGLESS => [104, 'BooleanFalseDefault'],
	DEFAULT_RIDE_TYPE => [105, 'RideType'],
    ];
}

1;
