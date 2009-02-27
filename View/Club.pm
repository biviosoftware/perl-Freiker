# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Club;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ride_date_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
	    CLUB_FREIKER_LIST
	    CLUB_FREIKER_CODE_IMPORT
	    CLUB_PRIZE_LIST
	    CLUB_PRIZE_COUPON_LIST
	    GREEN_GEAR_LIST
	)]),
	body => vs_paged_list(ClubRideDateList => [
	    'Ride.ride_date',
	    'ride_count',
	]),
    );
}

sub freiker_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
	    CLUB_FREIKER_SELECT
	    CLUB_RIDE_DATE_LIST
	    CLUB_FREIKER_CODE_IMPORT
	    CLUB_PRIZE_LIST
	    CLUB_PRIZE_COUPON_LIST
	    GREEN_GEAR_LIST
	)]),
	body => vs_paged_list(ClubFreikerList => [
	    'RealmOwner.display_name',
	    'freiker_codes',
	    'ride_count',
	    'prize_debit',
	    'prize_credit',
	    'parent_display_name',
	    'parent_email',
	]),
    );
}

sub freiker_select {
    return shift->internal_put_base_attr(
	body => vs_simple_form(FreikerSelectForm => [qw(
            FreikerSelectForm.FreikerCode.freiker_code
	)]),
	tools => TaskMenu([qw(
	    CLUB_RIDE_DATE_LIST
	    CLUB_FREIKER_CODE_IMPORT
	    CLUB_PRIZE_LIST
	    CLUB_PRIZE_COUPON_LIST
	)]),
    );
}

sub manual_ride_form {
    return shift->internal_body(vs_simple_form(ClubManualRideForm => [
	'ClubManualRideForm.add_days',
    ]));
}

sub prize {
    return shift->internal_body(vs_simple_form(ClubPrizeForm => [
	'ClubPrizeForm.PrizeRideCount.ride_count',
    ]));
}

sub prize_confirm {
    return shift->internal_body(vs_simple_form(ClubPrizeConfirmForm => [qw(
        ClubPrizeConfirmForm.Prize.name
	ClubPrizeConfirmForm.PrizeRideCount.ride_count
    )]));
}

sub prize_coupon_list {
     return shift->internal_body(vs_paged_list(ClubPrizeCouponList => [qw(
	PrizeCoupon.creation_date_time
	RealmOwner.display_name
	family_display_name
	freiker_codes
	Prize.name
     )]));
}

sub prize_list {
     return shift->internal_body(
	 vs_prize_list(ClubPrizeList => [qw(THIS_DETAIL CLUB_PRIZE)]));
}

sub prize_select {
     return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'CLUB_FREIKER_SELECT',
	    {
		task_id => 'CLUB_FREIKER_MANUAL_RIDE_FORM',
		query => {
		    'ListQuery.parent_id' => [qw(Model.ClubPrizeSelectList ->get_user_id)],
		},
	    },
	]),
	body => vs_prize_list(ClubPrizeSelectList =>
	     [qw(THIS_DETAIL CLUB_FREIKER_PRIZE_CONFIRM)]),
     );
}

sub register {
    return shift->internal_body(vs_simple_form(ClubRegisterForm => [qw{
	ClubRegisterForm.club_name
	ClubRegisterForm.club_size
	ClubRegisterForm.Website.url
	ClubRegisterForm.Address.zip
    }]));
}

1;
