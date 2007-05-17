# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeCouponRedeemForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->get_request->get('Model.PrizeCoupon')->create_receipt;
    return {
	task_id => 'next',
	query => {
	    'ListQuery.this' => $self->get('PrizeCoupon.coupon_code'),
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    'PrizeCoupon.coupon_code',
	],
    });
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    $self->internal_put_error('PrizeCoupon.coupon_code' => 'NOT_FOUND')
	unless $self->new_other('PrizeCoupon')->unsafe_load({
	    coupon_code => $self->get('PrizeCoupon.coupon_code'),
	});
    return;
}

1;
