# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeCoupon;
use strict;
use Bivio::Base 'Model.TxnCodeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub TXN_CODE_FIELD {
    return 'coupon_code';
}

sub create_receipt {
    my($self) = @_;
    return $self->new_other('PrizeReceipt')->create({
	coupon_code => $self->get('coupon_code'),
    });
}

sub execute {
    my($proto, $req) = @_;
#loads from this;
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'prize_coupon_t',
	columns => {
	    coupon_code => ['TxnCode', 'PRIMARY_KEY'],
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    prize_id => ['Prize.prize_id', 'NOT_NULL'],
	    user_id => ['User.user_id', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
	    ride_count => ['RideCount', 'NOT_NULL'],
	},
    });
}

1;
