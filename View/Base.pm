# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub VIEW_SHORTCUTS {
    return 'Freiker::ViewShortcuts';
}

sub internal_xhtml_adorned {
    return shift->call_super_before(\@_, sub {
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
	    wiki_widget_paypal_form => DIV_donate(
		Form(PayPalForm => Join([
		    SPAN_money('$'),
		    FormField('PayPalForm.amount', {class => 'money'}),
		    FormButton('ok_button'),
		])),
	    ),
	    xhtml_dock_left => If(
		And(
		    ['auth_realm', 'type', '->eq_forum'],
		),
		TaskMenu([
		    'FORUM_BLOG_LIST',
		    'FORUM_CALENDAR',
		    {
			task_id => 'FORUM_FILE',
			control => ['->can_user_execute_task', 'FORUM_FILE_CHANGE'],
		    },
		    'FORUM_MAIL_THREAD_ROOT_LIST',
		    'FORUM_MOTION_LIST',
		    'FORUM_TUPLE_USE_LIST',
		    'FORUM_WIKI_VIEW',
		]),
	    ),
	);
	view_unsafe_put(
	    xhtml_header_middle => _menu('HeaderMiddle'),
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
	);
	return;
    });
}

sub _menu {
    my($name) = @_;
    return WikiText('@b-menu ' . $name, {
	realm_id => vs_constant('site_realm_id'),
	task_id => 'SITE_WIKI_VIEW',
    });
}

1;
