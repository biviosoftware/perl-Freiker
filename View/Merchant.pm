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
    }]));
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
