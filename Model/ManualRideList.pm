# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideList;
use strict;
use Bivio::Base 'Model.NumberedList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FRL) = b_use('Model.FreikerRideList');

sub LOAD_ALL_SIZE {
    return 0;
}

sub internal_prepare_statement {
    my($self) = @_;
    $_FRL->assert_access($self, $self->get_query->get('parent_id'));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
