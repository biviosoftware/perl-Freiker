# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubPrizeForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(
	'PrizeRideCount.ride_count' =>
	    $self->req(qw(Model.ClubPrizeList PrizeRideCount.ride_count)));
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->new_other('PrizeRideCount')->create_or_update({
	prize_id =>
	    $self->req(qw(Model.ClubPrizeList Prize.prize_id)),
	ride_count => $self->get('PrizeRideCount.ride_count'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'PrizeRideCount.ride_count',
	],
    });
}

1;
