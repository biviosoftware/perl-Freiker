# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::TypeError;
use Bivio::Test;
Bivio::Test->new('Freiker::Type::Barcode')->unit([
    'Freiker::Type::Barcode' => [
	from_literal => [
	    a010 => 'a010',
	    a10 => [undef, Bivio::TypeError->BAR_CODE],
	],
	next_school => [
	    a000 => 'b000',
	    z000 => 'aa000',
	    zz000 => 'aaa000',
	    zzz000 => Bivio::DieCode->DIE,
	],
	extract_school => [
	    a000 => 'a000',
	    a001 => 'a000',
	],
    ],
]);
