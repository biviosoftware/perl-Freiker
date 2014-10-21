# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeReceipt;
use strict;
use Bivio::Base 'Model.TxnCodeBase';


sub TXN_CODE_FIELD {
    return 'receipt_code';
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->new($req)->load_this_from_request;
    $self->new_other('Prize')->unauth_load({
	prize_id => $self->new_other('PrizeCoupon')->load({
	    coupon_code => $self->get('coupon_code'),
	})->get('prize_id'),
    });
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'prize_receipt_t',
	columns => {
	    coupon_code => ['PrizeCoupon.coupon_code', 'PRIMARY_KEY'],
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    user_id => ['User.user_id', 'NOT_NULL'],
	    receipt_code => ['TxnCode', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
	},
    });
}

1;
