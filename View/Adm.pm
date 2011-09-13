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
	    'RealmOwner.display_name',
	    ['modified_date_time', {
		mode => 'DATE_TIME',
	    }],
	    {
		column_heading => String(vs_text('AdmFreikometerList.list_actions')),
		column_widget => ListActions([
		    [
			vs_text("AdmFreikometerList.list_action.FORUM_FILE_TREE_LIST"),
			'FORUM_FILE_TREE_LIST',
			URI({
			    task_id => 'FORUM_FILE_TREE_LIST',
			    realm => ['RealmOwner.name'],
			}),
			undef,
			['RealmOwner.name'],
		    ],
		]),
		column_data_class => 'list_actions',
	    },
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
	family_display_name
	freiker_codes
	Prize.name
     )]));
}

sub prize_list {
     return shift->internal_body(
	 vs_prize_list(AdmPrizeList => [qw(THIS_DETAIL ADM_PRIZE)]));
}

sub ride_summary_list {
    my($self) = @_;
    $self->internal_put_base_attr(
	vs_freiker_list_selector([qw(fr_begin fr_end)]));
    return $self->internal_body(
	vs_paged_list('AdmRideList', [
	    qw(ride_count current_miles calories co2_saved),
	], {
	    summary_only => 1,
	})
    );
}

1;
