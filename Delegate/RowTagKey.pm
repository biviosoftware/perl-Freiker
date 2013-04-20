# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INFO, $_TYPE) = _init();

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	@$_INFO,
    ],
}

sub internal_get_type {
    my($self) = @_;
    return $_TYPE->{$self->get_name} || shift->SUPER::internal_get_type(@_);
}

sub _init {
    my($type) = {};
    return (
	[map(
	    {
		$type->{$_->[0]} = $_->[2];
		($_->[0], $_->[1]);
	    }
	    [CLUB_SIZE => 100, 'ClubSize'],
	    [UNUSED_101 => 101],
	    [NEED_ACCEPT_TERMS => 102, 'BooleanFalseDefault'],
	    [HAS_GRADUATED => 103, 'BooleanFalseDefault'],
	    [ALLOW_TAGLESS => 104, 'BooleanFalseDefault'],
	    [DEFAULT_RIDE_TYPE => 105, 'RideType'],
	)],
	$type,
    );
}

1;
