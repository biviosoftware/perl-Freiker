# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::RealmName;
use strict;
use Bivio::Base 'Bivio::Delegate::SimpleRealmName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_display_name_and_zip {
    my($proto, $display_name, $zip) = @_;
    my($n) = $display_name;
    $n =~ s/^((\d|\W)*)//;
    my($numeric_prefix) = $1;
    $numeric_prefix =~ s/\D+//g;
    $n =~ s/^(?:the|an|a|saint|santa)\s+//i;
    $n =~ s/\b(co|corp|company|inc|ltd|llc)\.?$//i;
    $n =~ s/\s+.*|\W+//g;
    $n .= $numeric_prefix;
    $zip =~ s/[^a-z0-9]//ig;
    return lc(substr($n, 0, $proto->get_width - length($zip)) . $zip);
}

sub strip_school_classifiers {
    my($proto, $display_name) = @_;
    return join(' ',
        grep(!/^(?:elementary|middle|junior|high|school|k-8|charter|alternative|magnet|catholic)$/i,
            split(' ', $display_name)));
}

1;
