# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Merchant;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub info {
    return shift->internal_body(vs_simple_form(MerchantInfoForm => [qw{
	MerchantInfoForm.RealmOwner.display_name
	MerchantInfoForm.Address.street1
	MerchantInfoForm.Address.street2
	MerchantInfoForm.Address.city
	MerchantInfoForm.Address.state
	MerchantInfoForm.Address.zip
	MerchantInfoForm.Website.url
    }]));
}

sub pre_compile {
    my($self) = shift;
    my(@res) = $self->SUPER::pre_compile(@_);
    return unless $self->internal_base_type eq 'xhtml';
    $self->internal_put_base_attr(tools => TaskMenu([
	'MERCHANT_PRIZE',
	'MERCHANT_PRIZE_LIST',
	'MERCHANT_PRIZE_REDEEM',
    ]));
    return @res;
}

sub prize {
    return shift->internal_body(vs_simple_form(MerchantPrizeForm => [
	map(+{
	    field => "MerchantPrizeForm.Prize.$_",
	    control => ['Model.MerchantPrizeForm', 'full_edit'],
	}, qw(ride_count prize_status)),
	'MerchantPrizeForm.Prize.name',
	'MerchantPrizeForm.Prize.retail_price',
	'MerchantPrizeForm.Prize.detail_uri',
	'MerchantPrizeForm.image_file',
	'MerchantPrizeForm.Prize.description',
    ]));
}

sub prize_list {
    return shift->internal_body(List(MerchantPrizeList => [Link(
	Join([
	    Image(['->image_uri'], {
		alt_text => ['Prize.name'],
		class => 'in_list',
	    }),
	    SPAN_name(String(["Prize.name"], {hard_newlines => 0})),
	    ' ',
	    SPAN_desription(String(["Prize.description"], {hard_newlines => 0})),
	]),
	['->format_uri', qw(THIS_DETAIL MERCHANT_PRIZE)],
	{class => 'prize'},
    )]));
}

sub prize_redeem {
    return shift->internal_body(vs_simple_form(PrizeRedeemForm => [qw{
	PrizeRedeemForm.PrizeReceipt.coupon_code
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
