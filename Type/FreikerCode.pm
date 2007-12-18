# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::FreikerCode;
use strict;
use Bivio::Base 'Type.Integer';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = __PACKAGE__->use('Type.RealmName');

sub get_min {
    return 1;
}

sub to_realm_name {
    my(undef, $code) = @_;
    return $_RN->make_offline($code);
}

1;
