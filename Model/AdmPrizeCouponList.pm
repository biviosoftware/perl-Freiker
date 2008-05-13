# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmPrizeCouponList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [qw(
	    PrizeCoupon.realm_id
	    PrizeCoupon.coupon_code
	)],
        order_by => [qw(
	    PrizeCoupon.creation_date_time
	    Prize.name
	    RealmOwner.display_name
	)],
	other => [
            'PrizeCoupon.ride_count',
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    [qw(PrizeCoupon.user_id RealmOwner.realm_id)],
	],
    });
}

1;
