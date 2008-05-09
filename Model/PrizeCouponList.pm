# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeCouponList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_APL) = __PACKAGE__->use('Model.AdmPrizeList');
my($_LOC) = __PACKAGE__->use('Model.Website')->DEFAULT_LOCATION;

sub image_path {
    return shift->delegate_method($_APL, @_);
}

sub image_uri {
    return shift->delegate_method($_APL, @_);
}

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
	    ['RealmUser.role', ['FREIKER']],
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    'Prize.name',
	    'Prize.detail_uri',
	    'Website.url',
	    'RealmOwner.name',
	    'RealmOwner.display_name',
	    ['Prize.realm_id', 'RealmOwner.realm_id', 'Website.realm_id'],
	    ['Website.location', [$_LOC]],
	],
	auth_id => 'RealmUser.realm_id',
    });
}

1;
