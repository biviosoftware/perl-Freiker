# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::Role;
use strict;
use base 'Bivio::Delegate::Role';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	FREIKOMETER => [21],
	FREIKER => [22],
    ];
}

1;
