# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AvailablePrizeList;
use strict;
use Bivio::Base 'Model.AdmPrizeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	other => [
	    ['Prize.prize_status', [$self->use('Type.PrizeStatus')->AVAILABLE]],
	],
    });
}

1;
