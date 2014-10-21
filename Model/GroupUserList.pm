# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GroupUserList;
use strict;
use Bivio::Base 'Model';


sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    return $self->req->is_super_user
	|| !grep($_->eq_freikometer, @{$row->{roles}})
	? 1 : 0;
	
}

1;
