# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::BikeDateTime;
use strict;
use Bivio::Base 'Type.DateTime';

my($_TE) = b_use('Bivio.TypeError');

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value);
    return (undef, $_TE->SYNTAX_ERROR)
	unless $value =~ m{^\d{10}$};
    return $proto->from_unix($value);
}

1;
