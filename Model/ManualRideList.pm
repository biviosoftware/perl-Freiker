# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideList;
use strict;
use Bivio::Base 'Model.NumberedList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_load_none {
    my($proto, $req) = @_;
    $proto->new($req)->load_page({count => 0});
    return;
}

1;
