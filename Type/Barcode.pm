# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::Barcode;
use strict;
use base ('Bivio::Type::Name');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SCHOOL_SUFFIX) = '000';

sub REGEX {
    return qr/\b([a-z]{1,3}\d{3})\b/i;
}

sub extract_school {
    my($proto, $code) = @_;
    $code = $proto->from_literal_or_die($code);
    return ($code =~ /(\D+)/)[0] . $_SCHOOL_SUFFIX;
}

sub from_literal {
    my($proto) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $v;
    return (undef, Bivio::TypeError->BAR_CODE)
	unless $v =~ /^@{[$proto->REGEX]}$/i;
    return lc($v);
}

sub get_max {
    return 'zzz999';
}

sub get_min {
    return 'a000';
}

sub get_width {
    return 6;
}

sub next_school {
    my($proto) = shift;
    my($curr) = $proto->from_literal_or_die(@_);
    $curr =~ s/\d+//;
    $curr++;
    return length($curr) <= $proto->get_width - 3
	? $curr . $_SCHOOL_SUFFIX
	: Bivio::Die->die('out of bar codes');
}

1;
