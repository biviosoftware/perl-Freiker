# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Adm;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub freikometer_list {
    return shift->internal_body(
	vs_paged_list(AdmFreikometerList => [
	    'RealmOwner.name',
	    ['RealmFile.modified_date_time', {
		mode => 'DATE_TIME',
	    }],
	]),
    );

}

sub freiker_code_import {
    return shift->internal_body(vs_simple_form(FreikerCodeImportForm => [
        'FreikerCodeImportForm.source',
    ]));
}

sub prize {
    return shift->internal_body(vs_simple_form(AdmPrizeForm => [
	['AdmPrizeForm.Prize.prize_status', {wf_want_select => 1}],
	'AdmPrizeForm.Prize.ride_count',
	'AdmPrizeForm.Prize.name',
	'AdmPrizeForm.Prize.retail_price',
	'AdmPrizeForm.Prize.detail_uri',
	'AdmPrizeForm.image_file',
	'AdmPrizeForm.Prize.description',
    ]));
}

sub prize_coupon_list {
     return shift->internal_body(vs_paged_list(AdmPrizeCouponList => [qw(
	PrizeCoupon.creation_date_time
	RealmOwner.display_name
	freiker_codes
	Prize.name
     )]));
}

sub prize_list {
     return shift->internal_body(
	 vs_prize_list(AdmPrizeList => [qw(THIS_DETAIL ADM_PRIZE)]));
}

1;
