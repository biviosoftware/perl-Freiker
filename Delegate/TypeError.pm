# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::TypeError;
use strict;
use base 'Bivio::Delegate::SimpleTypeError';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	BAR_CODE => [
	    501,
	    undef,
	    'Invalid bar code.',
	],
	CANNOT_DELETE_CLASS => [
	    502,
	    undef,
	    'Implementation restriction: You cannot delete a class at this time.',
	],
	MERGE_OVERLAP => [
	    503,
	],
	EPC => [
	    504,
	    'Invalid EPC',
	],
    ];
}

1;
