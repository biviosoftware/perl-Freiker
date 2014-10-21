# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::Permission;
use strict;
use Bivio::Base 'Delegate.SimplePermission';


sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	UNUSED_51 => 51,
    ];
}

1;
