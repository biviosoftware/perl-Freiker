# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Family;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub freiker_add {
    return shift->internal_body(vs_simple_form(FreikerForm => [
        'FreikerForm.User.first_name',
	'FreikerForm.FreikerCode.freiker_code',
        _club_id('FreikerForm'),
	'-optional',
	'FreikerForm.birth_year',
        ['FreikerForm.User.gender', {class => 'radio_grid'}],
    ]));
}

sub freiker_code_add {
    return shift->internal_body(vs_simple_form(FreikerCodeForm => [
	'FreikerCodeForm.FreikerCode.freiker_code',
        _club_id('FreikerCodeForm'),
    ]));
}

sub freiker_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
            USER_PASSWORD
	    FAMILY_FREIKER_ADD
	)]),
	body => vs_list(FreikerList => [
	    ['RealmOwner.display_name' => {
		wf_list_link => {
		    task => 'FAMILY_FREIKER_RIDE_LIST',
		    query => 'THIS_CHILD_LIST',
		},
	    }],
# 	    [ride_count => {
# 		wf_list_link => {
# 		    task => 'FAMILY_FREIKER_RIDE_LIST',
# 		    query => 'THIS_CHILD_LIST',
# 		},
# 	    }],
# 	    [prize_debit => {
# 		wf_list_link => {
# 		    task => 'FAMILY_FREIKER_RIDE_LIST',
# 		    query => 'THIS_CHILD_LIST',
# 		},
# 	    }],
	    ['prize_credit', => {
		column_widget => If(
		    ['can_select_prize'],
		    Link(
			String(['prize_credit']),
			URI({
			    task_id => 'FAMILY_PRIZE_PICKUP',
			    query => [qw(->format_query THIS_DETAIL)],
			    no_context => 1,
		        }),
		    ),
		    String(['prize_credit']),
		    {column_data_class => If(
			['can_select_prize'],
			'select_prize',
			'amount_cell',
		    )},
		),
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
			$_ eq 'FAMILY_PRIZE_SELECT' ? ['can_select_prize'] : (),
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
	    }, qw(FAMILY_MANUAL_RIDE_FORM FAMILY_FREIKER_CODE_ADD)),
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
    return shift->internal_put_base_attr(
	want_page_print => 1,
	body => WithModel(PrizeCouponList => Prose(<<'EOF')),
<p class="prose">
Image(['->image_uri'], {alt_text => ['Prize.name']});
You may pick up your SPAN_strong(String(['Prize.name']));
provided by
Link(String(['RealmOwner.display_name']), ['Website.url']);
from Monday to Friday between SPAN_strong('3 and 5 p.m.'); at the
Freiker office
Link('2701 Iris Ave, Suite S, Boulder, CO 80304', 'http://maps.google.com/maps?q=2701+Iris+Ave,80304&ie=UTF8&ll=40.040314,-105.260181&spn=0.009709,0.023432&t=h&z=16&layer=c&cbll=40.036463,-105.260175&panoid=mLiTS7ISR2m8BMaAI9h-TA&cbp=1,352.7279533426744,,0,5');.
Our door is SPAN_strong('up stairs'); on the very south side of the building.
</p>
<p class="prose">
Your coupon code is SPAN_strong(String(['PrizeCoupon.coupon_code']));.  You
will need this code to receive your String(['Prize.name']);
</p>
EOF
    );
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

sub _club_id {
    my($form) = @_;
    return ["$form.Club.club_id" => {
	wf_class => 'Select',
	choices => ['Model.ClubList'],
	list_id_field => 'Club.club_id',
	list_display_field => 'RealmOwner.display_name',
	unknown_label => 'Select School',
    }];
}

1;
