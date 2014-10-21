# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Merchant;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub info {
    return shift->internal_body(vs_simple_form(MerchantInfoForm => [qw{
	MerchantInfoForm.RealmOwner.display_name
	MerchantInfoForm.Address.street1
	MerchantInfoForm.Address.street2
	MerchantInfoForm.Address.city
	MerchantInfoForm.Address.state
	MerchantInfoForm.Address.zip
	MerchantInfoForm.Address.country
	MerchantInfoForm.Website.url
    }]));
}

sub pre_compile {
    my($self) = shift;
    my(@res) = $self->SUPER::pre_compile(@_);
    return unless $self->internal_base_type eq 'xhtml';
    $self->internal_put_base_attr(tools =>
	TaskMenu([
	    'MERCHANT_PRIZE',
	    'MERCHANT_PRIZE_LIST',
	    'MERCHANT_PRIZE_REDEEM',
	], {
	    control => [[qw(->req auth_realm type)], '->eq_merchant'],
	}),
    );
    return @res;
}

sub prize {
    return shift->internal_body(vs_simple_form(MerchantPrizeForm => [
	'MerchantPrizeForm.Prize.name',
	'MerchantPrizeForm.Prize.retail_price',
	'MerchantPrizeForm.Prize.detail_uri',
	'MerchantPrizeForm.image_file',
	'MerchantPrizeForm.Prize.description',
    ]));
}

sub prize_list {
     return shift->internal_body(
	 vs_prize_list(MerchantPrizeList => [qw(THIS_DETAIL MERCHANT_PRIZE)]));
}

sub prize_redeem {
    return shift->internal_body(vs_simple_form(PrizeCouponRedeemForm => [qw{
	PrizeCouponRedeemForm.PrizeCoupon.coupon_code
    }]));
}

sub prize_receipt {
    return shift->internal_body(Join([
	DIV_prose('The coupon is valid.  Please complete the transaction as follows:'),
	OL_receipt(Join([
	    LI(Prose(q{Write on coupon: vs_text_as_prose('PrizeReceipt.receipt_code');: STRONG(['PrizeReceipt.receipt_code']);})),
	    LI(Prose(q{Put coupon in Freiker envelope.})),
	    LI(Prose(q{Give child String(['Prize.name']);})),
	])),
    ]));
}

1;
