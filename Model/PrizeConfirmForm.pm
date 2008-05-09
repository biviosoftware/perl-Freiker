# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeConfirmForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PRIZE_SELECT_LIST {
    return 'PrizeSelectList';
}

sub internal_pre_execute {
    my($self) = @_;
    $self->clear_errors;
    return $self->internal_put_error('Prize.name' => 'TOO_FEW')
	unless my $psl = $self->new_other($self->PRIZE_SELECT_LIST)
	->load_from_drilldown;
    $self->internal_put_field('Prize.name' => $psl->get('Prize.name'));
    $self->internal_put_field('PrizeRideCount.ride_count'
	=> $psl->get('PrizeRideCount.ride_count'));
    return;
}

sub execute_ok {
    my($self) = @_;
    my($psl) = $self->req('Model.' . $self->PRIZE_SELECT_LIST);
    my($pc) = $self->new_other('PrizeCoupon')->create({
        realm_id => $psl->get_distributor_id,
        user_id => $psl->get('User.user_id'),
        prize_id => $psl->get('Prize.prize_id'),
        ride_count => $psl->get('PrizeRideCount.ride_count'),
    });
    return {
        task_id => 'next',
        method => 'client_redirect',
	query => {
	    'ListQuery.parent_id' => $pc->get('user_id'),
	    'ListQuery.this' => $pc->get('coupon_code'),
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [qw(
	    Prize.name
	    PrizeRideCount.ride_count
	)],
    });
}

sub is_field_editable {
    return 0;
}

1;
