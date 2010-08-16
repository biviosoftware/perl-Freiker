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
	xhtml_dock_right => JoinMenu([
	    RealmDropDown('club'),
	    ForumDropDown(),
	    HelpWiki(),
	    UserSettingsForm(),
	    UserState(),
	]),
	xhtml_dock_left => TaskMenu([
	    'FAMILY_FREIKER_LIST',
	    'CLUB_FREIKER_LIST',
#	    RealmDropDown('merchant'),
	    SiteAdminDropDown([
		'ADM_FREIKOMETER_LIST',
		'ADM_PRIZE_LIST',
		'ADM_PRIZE_COUPON_LIST',
		'CLUB_REGISTER',
#		'MERCHANT_REGISTER',
		{
		    realm => 'site-contact',
		    task_id => 'FORUM_CRM_THREAD_ROOT_LIST',
		},
	    ]),
#	    'FORUM_BLOG_LIST',
#	    'FORUM_WIKI_VIEW',
	    If([['->req'], '->can_user_execute_task', 'FORUM_FILE_CHANGE'],
	       DropDown(
		   String('more'),
		   DIV_dd_menu(TaskMenu([qw(
                       FORUM_FILE_TREE_LIST
		       GROUP_TASK_LOG
		       GROUP_USER_LIST
	               FORUM_CRM_THREAD_ROOT_LIST
		   )]), {id => 'more_drop_down'}),
	     ),
	   ),
	]),
	xhtml_header_left => undef,
	xhtml_header_right => vs_header_su_link(
	    Link(
		Image('logo'),
		URI(b_use('Action.ClientRedirect')
		    ->uri_parameters(
			'http://www.boltage.org', 'task_id')),
	    ),
	),
	xhtml_footer_left => DIV(q{Boltage&nbsp;&gt;&nbsp;&nbsp;&nbsp;Let's make it a way of life}),
	map(
	    ("xhtml_footer_$_->[0]" => Link(
		$_->[1],
		URI({
		    task_id => 'CLIENT_REDIRECT',
		    query => {
			b_use('Action.ClientRedirect')->QUERY_TAG
			    => 'http://www.facebook.com/pages/Boltage/10150154921405078?ref=ts',
		    },
		}),
	    )),
	    [center => Simple('Find us on FaceBook')],
	    [right => Image('social_fb')],
	),
    );
    return @res;
}

1;
