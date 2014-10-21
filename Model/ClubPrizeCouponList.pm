# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubPrizeCouponList;
use strict;
use Bivio::Base 'Model.AdmPrizeCouponList';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	auth_id => 'RealmUser.realm_id',
    });
}

1;
