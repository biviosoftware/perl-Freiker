# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeCouponList;
use strict;
use Bivio::Base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => ['PrizeCoupon.coupon_code'],
        order_by => [
	    [qw(PrizeCoupon.coupon_code PrizeReceipt.coupon_code(+))],
	    'PrizeCoupon.creation_date_time',
	],
	other => [
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    'Prize.name',
	    'Prize.detail_uri',
	    'PrizeReceipt.receipt_code',
	],
	auth_id => [qw(PrizeCoupon.realm_id PrizeReceipt.realm_id(+))],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where($stmt->IS_NULL('PrizeReceipt.receipt_code'));
    return;
}

1;
