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
	parent_id => [qw(PrizeCoupon.user_id RealmUser.user_id)],
        order_by => [
	    'PrizeCoupon.creation_date_time',
	],
	other => [
            'PrizeCoupon.ride_count',
	    ['RealmUser.role', ['MEMBER']],
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    'Prize.name',
	    'Prize.detail_uri',
#	    'PrizeReceipt.receipt_code',
	],
	auth_id => 'RealmUser.realm_id',
    });
}

1;
