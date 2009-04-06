# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Club;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
sub ride_date_list {
    return shift->internal_put_base_attr(
	_tools_rides('CLUB_RIDE_DATE_LIST'),
	body => vs_paged_list(ClubRideDateList => [
	    'Ride.ride_date',
	    'ride_count',
	]),
    );
}

sub freiker_list {
    return shift->internal_put_base_attr(
	_tools_rides('CLUB_FREIKER_LIST'),
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
	_tools_prizes('CLUB_FREIKER_SELECT'),
	body => vs_simple_form(FreikerSelectForm => [qw(
            FreikerSelectForm.FreikerCode.freiker_code
	)]),
    );
}

sub manual_ride_form {
    return shift->internal_put_base_attr(
	_tools_prizes('CLUB_FREIKER_MANUAL_RIDE_FORM'),
	body => vs_simple_form(ClubManualRideForm => [
	    'ClubManualRideForm.add_days',
	]),
    );
}

sub prize {
    return shift->internal_body(vs_simple_form(ClubPrizeForm => [
	'ClubPrizeForm.PrizeRideCount.ride_count',
    ]));
}

sub prize_confirm {
    return shift->internal_put_base_attr(
	_tools_prizes('CLUB_FREIKER_PRIZE_CONFIRM'),
	body => vs_simple_form(ClubPrizeConfirmForm => [qw(
	    ClubPrizeConfirmForm.Prize.name
	    ClubPrizeConfirmForm.PrizeRideCount.ride_count
	)]),
    );
}

sub prize_coupon_list {
    return shift->internal_put_base_attr(
	_tools_prizes('CLUB_FREIKER_PRIZE_CONFIRM'),
	body => vs_paged_list(ClubPrizeCouponList => [qw(
	    PrizeCoupon.creation_date_time
	    RealmOwner.display_name
	    family_display_name
	    freiker_codes
	    Prize.name
	)]),
    );
}

sub prize_list {
    return shift->internal_put_base_attr(
	_tools_prizes('CLUB_PRIZE_LIST'),
	body => vs_prize_list(ClubPrizeList => [qw(THIS_DETAIL CLUB_PRIZE)]),
    );
}

sub prize_select {
     return shift->internal_put_base_attr(
	_tools('CLUB_FREIKER_PRIZE_SELECT', [
	    'CLUB_PRIZE_COUPON_LIST',
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
	ClubRegisterForm.Address.street1
	ClubRegisterForm.Address.street2
	ClubRegisterForm.Address.city
	ClubRegisterForm.Address.state
	ClubRegisterForm.Address.zip
	ClubRegisterForm.Address.country
    }]));
}

sub ride_fill_form {
     return shift->internal_put_base_attr(
	_tools_rides('CLUB_RIDE_FILL_FORM'),
	body => vs_simple_form(ClubRideFillForm => [
	    'ClubRideFillForm.Ride.ride_date',
	]),
    );
}

sub _tools {
    my($curr, $extras) = @_;
    return (tools => TaskMenu([
	grep($curr ne $_,
	    $extras ? @$extras : (),
	    qw(
		CLUB_PRIZE_LIST
		CLUB_PRIZE_COUPON_LIST
		GREEN_GEAR_LIST
		CLUB_FREIKER_CODE_IMPORT
	    ),
	),
    ]));
}

sub _tools_prizes {
    return _tools(shift, [qw(
	CLUB_PRIZE_COUPON_LIST
	CLUB_FREIKER_SELECT
    )]);
}

sub _tools_rides {
    return _tools(shift, [qw(
	CLUB_RIDE_FILL_FORM
	CLUB_RIDE_DATE_LIST
    )]);
}

1;
