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

sub freiker_code_reallocate_confirm {
    my($self) = @_;
    return shift->internal_body(
	vs_simple_form('AdmFreikerCodeReallocateConfirmationForm'),
    );
}

sub freiker_code_reallocate_form {
    my($self) = @_;
    my($model) = 'AdmFreikerCodeReallocateForm';
    return shift->internal_body(
	vs_simple_form($model => [
	    ["$model.source.Club.club_id" => {
		wf_class => 'Select',
		choices => ['Model.ClubList'],
		list_id_field => 'Club.club_id',
		list_display_field => 'RealmOwner.display_name',
		unknown_label => vs_text('ClubList.unknown_label'),
	    }],
	    ["$model.dest.Club.club_id" => {
		wf_class => 'Select',
		choices => ['Model.ClubList'],
		list_id_field => 'Club.club_id',
		list_display_field => 'RealmOwner.display_name',
		unknown_label => vs_text('ClubList.unknown_label'),
	    }],
	    "$model.FreikerCode.freiker_code",
	]),
    );
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

sub summary_by_school_list {
    my($self) = @_;
    $self->internal_put_base_attr(
	vs_freiker_list_selector([qw(fr_begin fr_end)]));
    return $self->internal_body(
	vs_list('AdmSummaryBySchoolList', [
	    ['realm_display_name', {
		column_summary_value =>
		    vs_text('AdmSummaryBySchoolList.display_name_summary_value'),
	    }],
	    qw(ride_count current_miles calories co2_saved),
	], {
	    trailing_separator => 1,
	    summarize => 1,
	}),
    );
}

1;
