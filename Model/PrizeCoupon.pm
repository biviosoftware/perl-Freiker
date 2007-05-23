# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeCoupon;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub TXN_CODE_FIELD {
    return 'coupon_code';
}

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $self->get_instance('Lock')->execute_unless_acquired($req);

    my($code);
    my($pc) = $self->new_other('PrizeCoupon');

    # TODO: loop TxnCode->size times
    foreach my $i (1..1000) {
	$code = Freiker::Type::TxnCode->generate_random();
	last
	    unless $pc->unsafe_load({
	        coupon_code => $code,
	    });
    }
    Bivio::Die->die('No more Cupon codes!')
        if $pc->is_loaded();

    $values->{coupon_code} = $code;

    return shift->SUPER::create(@_);
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
