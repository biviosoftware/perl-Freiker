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
	primary_key => [
	    [qw(PrizeCoupon.realm_id PriceReceipt.realm_id(+))],
	    [qw(PrizeCoupon.coupon_code PriceReceipt.coupon_code(+))],
	],
        order_by => [
	    'PrizeCoupon.creation_date_time',
	    'Prize.name',
	    'RealmOwner.display_name',
	],
	other => [
            'PrizeCoupon.ride_count',
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    [qw(PrizeCoupon.user_id RealmOwner.realm_id PrizeReceipt.user_id(+))],
	],
    });
}

1;
