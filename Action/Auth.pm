# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::Auth;
use strict;
use Bivio::Base 'Biz.Action';

my($_DC) = b_use('Bivio.DieCode');

sub execute_is_sub_or_super_user {
    my($proto, $req) = @_;
    $_DC->FORBIDDEN->throw_die('must be substitute or super user')
	unless $req->is_super_user || $req->is_substitute_user;
    return;
}

1;
