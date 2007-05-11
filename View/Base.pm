# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VIEW_SHORTCUTS {
    return 'Freiker::ViewShortcuts';
}

sub internal_xhtml_adorned {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_xhtml_adorned(@_);
    view_unsafe_put(
	base_realm => If(
	    [qw(auth_realm ->has_owner)],
	    Join([
		String(['auth_realm', 'owner', 'display_name']),
		If([qw(auth_realm type ->eq_club)],
		   String(' Family')),
	    ]),
	    'Freiker',
	),
	base_menu => TaskMenu([
	    map(+{xlink => SiteRoot($_)},
		qw(hm_parents hm_press hm_prizes hm_sponsors hm_wheels)),
	]),
	xhtml_title => Prose(
	    vs_text([sub {"xhtml.title.$_[1]"}, ['task_id', '->get_name']]),
	),
    );
    view_unsafe_put(
	xhtml_main_right => ' ',
	xhtml_main_left => Join([
	    If(['auth_user'],
# List of Family, Schools, and Stores
	       [sub {
		    TaskMenu([
			'FAMILY_FREIKER_LIST',
			map(+{
			    task_id => 'CLUB_FREIKER_LIST',
			    label => String($_->{'RealmOwner.display_name'}),
			    realm => $_->{'RealmOwner.name'},
			    query => undef,
			}, sort {
			    $a->{'RealmOwner.display_name'}
				cmp $b->{'RealmOwner.display_name'}
			} @{shift->get_request->map_user_realms(
			    undef,
			    {
				'RealmOwner.realm_type' => Bivio::Auth::RealmType->CLUB,
				'RealmUser.role' => Bivio::Auth::Role->ADMINISTRATOR,
			    },
			)}),
			'CLUB_REGISTER',
		    ]),
		}],
		If([sub {
			my($req) = shift->get_request;
			return 0
			    if $req->get('task_id')->get_name =~ /LOGIN|USER_CREATE/;
			Bivio::Biz::Model->new($req, 'ContextlessUserLoginForm')->process;
			return 1;
		   }],
		   RoundedBox(
		       Form(ContextlessUserLoginForm =>
			   Join([
			       map((
				   DIV_label(String(vs_text("ContextlessUserLoginForm.$_"))),
				   FormField("ContextlessUserLoginForm.$_", {size => 15}),
			       ), qw(login RealmOwner.password)),
			       StandardSubmit(['ok_button']),
			       Link('Not Registered?', 'USER_CREATE', {
				   class => 'label',
			       }),
			   ]),
			   {
			       action => URI({
				   task_id => 'LOGIN',
				   no_context => 1,
			       }),
			   },
			), {
			    class => 'login',
			},
		   ),
		   ' ',
	       ),
	    ),
	    view_widget_value('base_menu'),
	]),
	xhtml_topic => view_widget_value('xhtml_title'),
	xhtml_header_middle => DIV_donate(
	    Link(
		Join([
		    Image('donate', 'Please donate'),
		    DIV_msg(q{It's tax-deductible!}),
		]),
		'SITE_DONATE',
	    ),
	),
	xhtml_header_right => DIV_user_state(
	    Director([qw(user_state ->get_name)], {
		JUST_VISITOR => XLink('user_create_no_context'),
		LOGGED_OUT => XLink('login_no_context'),
		LOGGED_IN => XLink('LOGOUT'),
	    }),
	),
	xhtml_footer_middle => TaskMenu([
	    'SITE_DONATE',
	    'SITE_ROOT',
	    XLink('login_no_context'),
	    'USER_CREATE',
	]),
    );
    return @res;
}

1;
