# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::MerchantPrizeList;
use strict;
use Bivio::Base 'Model.AllPrizeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NOT_FOUND_IF_EMPTY {
    return 1;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        auth_id => ['Prize.realm_id'],
    });
}

1;
