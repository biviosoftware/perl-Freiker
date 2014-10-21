# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::RealmType;
use strict;
use Bivio::Base 'Delegate';


sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	MERCHANT => 23,
	SCHOOL_CLASS => 24,
    ];
}

1;
