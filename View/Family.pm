# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Family;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub freiker_list {
    return shift->internal_put_base_attr(
	vs_freiker_list_selector([qw(fr_begin fr_end)]),
	tools => TaskMenu([qw(
	    FAMILY_FREIKER_ADD
	)]),
	body => vs_list(FreikerList => [
	    ['User.first_name' => {
		wf_list_link => {
		    task => 'FAMILY_FREIKER_RIDE_LIST',
		    query => 'THIS_CHILD_LIST',
		},
		column_order_by => ['User.first_name_sort'],
	    }],
	    'freiker_codes',
	    'ride_count',
	    vs_freiker_list_actions(qw(FAMILY FreikerList)),
	]),
    );
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
Boltage office
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

1;
