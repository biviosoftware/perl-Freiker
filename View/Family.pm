# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Family;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub freiker_add {
    return shift->internal_body(vs_simple_form(FreikerForm => [qw{
        FreikerForm.User.first_name
	FreikerForm.FreikerCode.freiker_code
    },
	['FreikerForm.Club.club_id' => {
	    wf_class => 'Select',
	    choices => ['Model.ClubSelectList'],
	    list_id_field => 'Club.club_id',
	    list_display_field => 'RealmOwner.display_name',
	}],
    qw{
	-optional
	FreikerForm.birth_year
    },
        ['FreikerForm.User.gender', {class => 'radio_grid'}],
    ]));
}

sub freiker_code_add {
    return shift->internal_body(vs_simple_form(FreikerCodeForm => [qw{
	FreikerForm.FreikerCode.freiker_code
    }]));
}

sub freiker_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
            USER_PASSWORD
	    FAMILY_FREIKER_ADD
	)]),
	body => vs_list(FreikerList => [
	    'RealmOwner.display_name',
	    [ride_count => {
		wf_list_link => {
		    task => 'FAMILY_FREIKER_RIDE_LIST',
		    query => 'THIS_CHILD_LIST',
		},
	    }],
	    {
		column_heading => String(vs_text("FreikerList.list_actions")),
		column_widget => ListActions([map({
		    [
			vs_text("FreikerList.list_action.$_"),
			$_,
			URI({
			    task_id => $_,
			    query => [qw(->format_query THIS_CHILD_LIST)],
			    no_context => 1,
			}),
		    ];
		} qw(FAMILY_FREIKER_RIDE_LIST FAMILY_MANUAL_RIDE_FORM FAMILY_FREIKER_CODE_ADD))]),
# FAMILY_PRIZE_COUPON_LIST
		column_data_class => 'list_actions',
	    },
	]),
    );
}

sub freiker_ride_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'USER_PASSWORD',
	    map(+{
		task_id => $_,
		query => {
		    'ListQuery.parent_id' => [[qw(Model.FreikerRideList ->get_query)], 'parent_id'],
		},
	    }, qw(FAMILY_MANUAL_RIDE_FORM FAMILY_FREIKER_CODE_ADD FAMILY_PRIZE_COUPON_LIST)),
	    {
		task_id => 'FAMILY_FREIKER_LIST',
		label => 'back_to_family',
	    },
	]),
	body => vs_paged_list(FreikerRideList => [
	    'Ride.ride_date',
	]),
    );
}

sub manual_ride_form {
    return shift->internal_body(vs_simple_form(ManualRideForm => [qw{
        ManualRideForm.Ride.ride_date
    }]));
}

sub prize_confirm {
    return shift->internal_body(vs_simple_form(PrizeConfirmForm => [qw(
        PrizeConfirmForm.Prize.name
	PrizeConfirmForm.PrizeRideCount.ride_count
    )]));
}

sub prize_coupon {
    return shift->internal_body(List(PrizeCouponList => [
        Prose(<<'EOF'),
Congratulations!  You may go to your local distributor to pick up
your prize.
<br />
Prize: String(['Prize.name']);<br />
Code: String(['PrizeCoupon.coupon_code']);<br />
EOF
    ]));
}

sub prize_coupon_list {
#TODO: allow delete of prize
    return shift->internal_body(vs_list(FreikerPrizeCouponList => [qw(
	Prize.name
    )]));
}

sub prize_select {
     return shift->internal_body(
	 vs_prize_list(PrizeSelectList => [qw(THIS_DETAIL FAMILY_PRIZE_CONFIRM)]));
}

1;
