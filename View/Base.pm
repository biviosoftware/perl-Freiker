# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_R) = b_use('Model.Ride');

sub VIEW_SHORTCUTS {
    return 'Freiker::ViewShortcuts';
}

sub internal_xhtml_adorned_attrs {
    my(@res) = shift->SUPER::internal_xhtml_adorned_attrs(@_);
    view_unsafe_put(
	xhtml_title => Join([
	    If([qw(auth_realm type ->eq_club)],
	       Join([
		   String([qw(auth_realm owner display_name)]),
		   ': ',
	       ]),
	    ),
	    Prose(vs_text(
		[sub {"xhtml.title.$_[1]"}, ['task_id', '->get_name']])),
	]),
	wiki_widget_contact => Link(
	    String('our contact form'),
	    'GENERAL_CONTACT',
	),
	wiki_widget_ride_count_all => String(
	    [[sub {$_R->count_all}], 'HTMLFormat.Amount', 0, 0, 0],
	),
	wiki_widget_paypal_form => DIV_donate(
		AuxiliaryForm(PayPalForm => Join([
		SPAN_money('$'),
		FormField('PayPalForm.amount', {class => 'money'}),
		FormButton('ok_button'),
	    ])),
	),
# #TODO: Add Your Family * Schools * Merchants * Admin
	xhtml_dock_left => TaskMenu([
	    RealmDropDown('club'),
	    RealmDropDown('merchant'),
	    SiteAdminDropDown([
		'ADM_FREIKOMETER_LIST',
		'ADM_PRIZE_LIST',
		'ADM_PRIZE_COUPON_LIST',
		'CLUB_REGISTER',
		'MERCHANT_REGISTER',
	    ]),
	    'FORUM_BLOG_LIST',
	    'FORUM_CALENDAR',
	    {
		task_id => 'FORUM_FILE',
		control => [['->req'], '->can_user_execute_task', 'FORUM_FILE_CHANGE'],
	    },
	    'FORUM_MAIL_THREAD_ROOT_LIST',
#	    'FORUM_MOTION_LIST',
	    'FORUM_WIKI_VIEW',
	]),
    );
    view_unsafe_put(
	xhtml_header_middle => RoundedBox(_menu('HeaderMiddle')),
	xhtml_footer_left => '',
	xhtml_footer_right => '',
	xhtml_footer_middle => Join([
	    _menu('FooterMiddle'),
	    DIV_legal(Join([
		SPAN_copyright(Join([
		    '&copy; ',
		    $_DT->now_as_year,
		    ' ',
		    vs_text_as_prose('site_copyright'),
		])),
		SPAN_tagline('Every Ride Counts!&trade;'),
		Link(
		    'Software by bivio',
		    'http://www.bivio.biz',
		    {class => 'software_by_bivio'},
		),
	    ])),
	]),
	xhtml_main_left => Or(And(
	    IfWiki('.*', 1),
	    Director(['->req', 'path_info'], {
		map((qr{^/(?:@{[join('|', @$_)]})$}is
		    => RoundedBox(_menu("$_->[0]MainLeft"), 'left_nav')),
		    [qw(About_Us History Board_And_Staff In_The_News)],
		    [qw(How_It_Works Freikometer Prizes Results FAQ)],
		    [qw(Support_Freiker Volunteer Sponsors)],
		    [qw(Parents_And_Kids)],
		    [qw(Schools)],
		),
	    }, '', ''),
	    ),
	    If(Not(
		[['->req', 'task_id'],
		 '->equals_by_name', 'user_create', 'login']),
	       If(['auth_user_id'],
		  RoundedBox(_menu('HomeMainLeft'), 'left_nav'),
		  RoundedBox(
		      AuxiliaryForm(ContextlessUserLoginForm => Join([
			  map((
			      DIV_label(String(vs_text("ContextlessUserLoginForm.$_"))),
			      FormField("ContextlessUserLoginForm.$_", {size => 15}),
			  ), qw(login RealmOwner.password)),
			  StandardSubmit('ok_button'),
			  Link('Not Registered?', 'USER_CREATE', {
			      class => 'label',
			  }),
		      ]), {
			  action => URI({
			      task_id => 'LOGIN',
			      no_context => 1,
			  }),
		      }),
		      'login',
		  ),
	      ),
	   ),
        ),
    );
    return @res;
}

sub xx {
    my($proto, $args, $op) = @_;
	#(caller(0))[0]->super_for_method($proto->my_caller);
#    my($res) = Bivio::UI::View::ThreePartPage::internal_xhtml_adorned($proto);
    $op->($proto);
#    return $res;
#    return;
#     my($super) = [$sub->($proto, @$args)];
#     my($my) = $op->($proto, $args, $super) || $super;
#     return wantarray ? @$my : $my->[0];
}

sub internal_xhtml_grid3 {
    my($self, $name) = @_;
    my($w) = shift->SUPER::internal_xhtml_grid3(@_);
    return $name eq 'main' ? RoundedBox($w, 'fr_main_rounded_box') : $w;
}

sub _menu {
    my($name) = @_;
    return WikiText('@b-menu ' . $name, {
	realm_id => vs_constant('site_realm_id'),
	task_id => 'SITE_WIKI_VIEW',
    });
}

1;
