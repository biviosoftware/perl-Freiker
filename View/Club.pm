# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Club;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
sub ride_date_list {
    return shift->internal_body_and_tools(
	vs_paged_list(ClubRideDateList => [
	    'Ride.ride_date',
	    'ride_count',
	]),
    );
}

sub freiker_list {
    return shift->internal_body_and_tools(
	vs_paged_list(ClubFreikerList => [
	    'RealmOwner.display_name',
	    'freiker_codes',
	    'ride_count',
	    'prize_debit',
	    'prize_credit',
	    'parent_display_name',
	    'parent_email',
	]),
	[
	    {
		task_id => 'CLUB_FREIKER_LIST_CSV',
		query => [\&_csv_query],
	    },
	],
    );
}

sub freiker_list_csv {
    my($self) = @_;
    return shift->internal_body(CSV(ClubFreikerList => [qw(
	RealmOwner.display_name
	freiker_codes
	ride_count
	prize_debit
	prize_credit
	parent_display_name
	parent_email
    )]));
}

sub freiker_select {
    return shift->internal_body_and_tools(
	vs_simple_form(FreikerSelectForm => [qw(
            FreikerSelectForm.FreikerCode.freiker_code
	)]),
    );
}

sub internal_body_and_tools {
    my($proto, $body, $extra) = @_;
    return shift->internal_put_base_attr(
	body => $body,
	tools => If(
	    [sub {
		 my($req) = shift->req;
		 my($k) = __PACKAGE__. '.wheel_tools_drop_down';
		 my($ok) = !$req->unsafe_get($k);
		 $req->put($k => 1);
		 return $ok;
	    }],
	    TaskMenu([
		@{$extra || []},
		DropDown(
		    String('Wheel Tools'),
		    DIV_dd_menu(
			TaskMenu([
			    'CLUB_PRIZE_LIST',
			    'GREEN_GEAR_FORM',
			    'CLUB_FREIKER_SELECT',
			    'CLUB_PRIZE_COUPON_LIST',
			    'CLUB_RIDE_FILL_FORM',
			    'CLUB_FREIKER_LIST',
			    'GREEN_GEAR_LIST',
			    'CLUB_FREIKER_CODE_IMPORT',
			    'CLUB_RIDE_DATE_LIST',
			], {class => 'no-match'}),
#TODO: need generate unique id, because tool shows up twice for rendering
			{id => 'wheel_tools_drop_down'},
		    ),
		),
	    ]),
	    XLink('back_to_top'),
	),
    );
}

sub manual_ride_form {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubManualRideForm => [
	    'ClubManualRideForm.add_days',
	]),
    );
}

sub prize {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubPrizeForm => [
	    'ClubPrizeForm.PrizeRideCount.ride_count',
	]),
    );
}

sub prize_confirm {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubPrizeConfirmForm => [qw(
	    ClubPrizeConfirmForm.Prize.name
	    ClubPrizeConfirmForm.PrizeRideCount.ride_count
	)]),
    );
}

sub prize_delete {
    return shift->internal_body_and_tools(
	vs_simple_form('ClubPrizeDeleteForm'),
    );
}

sub prize_coupon_list {
    return shift->internal_body_and_tools(
	vs_paged_list(ClubPrizeCouponList => [qw(
	    PrizeCoupon.creation_date_time
	    RealmOwner.display_name
	    family_display_name
	    freiker_codes
	    Prize.name
	), {
	    column_heading => String(vs_text("ClubPrizeCouponList.list_actions")),
	    column_widget => ListActions([
		[
		    vs_text('ClubPrizeCouponList.list_action.CLUB_FREIKER_PRIZE_DELETE'),
		    'CLUB_FREIKER_PRIZE_DELETE',
		    URI({
			task_id => 'CLUB_FREIKER_PRIZE_DELETE',
			query => [qw(->format_query THIS_DETAIL)],
			no_context => 1,
		    }),
		],
	    ], {
		column_data_class => 'list_actions',
	    }),
        }]),
    );
}

sub prize_list {
    return shift->internal_body_and_tools(
	vs_prize_list(ClubPrizeList => [qw(THIS_DETAIL CLUB_PRIZE)]),
    );
}

sub prize_select {
    return shift->internal_body_and_tools(
	vs_prize_list(ClubPrizeSelectList =>
	     [qw(THIS_DETAIL CLUB_FREIKER_PRIZE_CONFIRM)]),
	[
	    {
		task_id => 'CLUB_FREIKER_MANUAL_RIDE_FORM',
		query => {
		    'ListQuery.parent_id' => [qw(Model.ClubPrizeSelectList ->get_user_id)],
		},
	    },
	],
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
     return shift->internal_body_and_tools(
	vs_simple_form(ClubRideFillForm => [
	    'ClubRideFillForm.Ride.ride_date',
	]),
    );
}

sub _csv_query {
    my($req) = shift->req;
    my($q) = $req->get('Model.ClubFreikerList')->get_query;
    return {
	map($q->get($_) ? ("ListQuery.$_" => $q->get($_)) : (), qw(begin_date date)),
    };
}

1;
