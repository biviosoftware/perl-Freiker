# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerPrizeCouponList;
use strict;
use Bivio::Base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        parent_id => ['RealmUser.user_id'],
	auth_id => 'RealmUser.realm_id',
	primary_key => [
	    [qw(PrizeCoupon.realm_id PrizeReceipt.realm_id(+))],
	    [qw(PrizeCoupon.coupon_code PrizeReceipt.coupon_code(+))],
	],
	other => [
	    ['RealmUser.role', ['MEMBER']],
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    'Prize.name',
	],
    });
}

1;
