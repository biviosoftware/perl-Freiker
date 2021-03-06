# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideList;
use strict;
use Bivio::Base 'Model.NumberedList';

my($_FRL) = b_use('Model.FreikerRideList');

sub LOAD_ALL_SIZE {
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        parent_id => ['Ride.user_id'],
    });
}

sub internal_prepare_statement {
    my($self) = @_;
    $_FRL->assert_access($self, $self->get_query->get('parent_id'));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
