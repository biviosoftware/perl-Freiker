# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::RealmName;
use strict;
use Bivio::Base 'Bivio::Delegate::SimpleRealmName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_display_name_and_zip {
    my($proto, $display_name, $zip) = @_;
    my($n) = $display_name;
    $n =~ s/^(the|an|a|saint|santa)\s+//i;
    $n =~ s/\s+.*|\W+//g;
    return lc(substr($n, 0, $proto->get_width - length($zip)) . $zip);
}

1;