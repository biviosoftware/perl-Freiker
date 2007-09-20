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
	xhtml_title => Prose(
#TODO: Incorporate RealmOwner.display_name
#TODO: Give parent access to freiker's realm?
	    vs_text([sub {"xhtml.title.$_[1]"}, ['task_id', '->get_name']]),
	),
	wiki_widget_contact => vs_gears_email(),
	wiki_widget_paypal_form => DIV_donate(
	    Form(PayPalForm => Join([
		SPAN_money('$'),
		FormField('PayPalForm.amount', {class => 'money'}),
		FormButton('ok_button'),
	    ])),
	),
    );
    view_unsafe_put(
	xhtml_main_right => '',
	xhtml_main_left => Join([
	    If(['auth_user'],
# List of Family, Schools, and Stores
	       [sub {
		    my($req) = shift->get_request;
#TODO: Refactor: Make a redirect task for realms?
		    TaskMenu([
			'ADM_SUBSTITUTE_USER',
			'FAMILY_FREIKER_LIST',
			map(+{
			    task_id => 'CLUB_FREIKER_LIST',
			    label => String($_->{'RealmOwner.display_name'}),
			    realm => $_->{'RealmOwner.name'},
			    query => undef,
			}, sort {
			    $a->{'RealmOwner.display_name'}
				cmp $b->{'RealmOwner.display_name'}
			} @{$req->map_user_realms(
			    undef,
			    {
				'RealmOwner.realm_type' => Bivio::Auth::RealmType->CLUB,
				'RealmUser.role' => Bivio::Auth::Role->ADMINISTRATOR,
			    },
			)}),
# 			map(+{
# 			    task_id => 'MERCHANT_PRIZE_LIST',
# 			    label => String($_->{'RealmOwner.display_name'}),
# 			    realm => $_->{'RealmOwner.name'},
# 			    query => undef,
# 			}, sort {
# 			    $a->{'RealmOwner.display_name'}
# 				cmp $b->{'RealmOwner.display_name'}
# 			} @{$req->map_user_realms(
# 			    undef,
# 			    {
# 				'RealmOwner.realm_type' => Bivio::Auth::RealmType->FORUM,
# 			    },
# 			)}),
			'CLUB_REGISTER',
# 			'MERCHANT_REGISTER',
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
	    WikiText('@b-menu.left_nav Main', {
		realm_id => vs_constant('site_realm_id'),
		realm_name => vs_constant('site_realm_name'),
		task_id => 'FORUM_WIKI_VIEW',
	    }),
	]),
	xhtml_header_middle => DIV_donate(
	    Link(
		Join([
		    Image('donate', 'Please donate'),
		    DIV_msg(q{It's tax-deductible!}),
		]),
		URI({
		    realm => vs_constant('site_realm_name'),
		    task_id => 'PAYPAL_FORM',
		    query => undef,
		}),
	    ),
	),
	xhtml_footer_middle => TaskMenu([
	    {
		task_id => 'PAYPAL_FORM',
		realm => vs_constant('site_realm_name'),
		query => undef,
	    },
	    'SITE_ROOT',
	    XLink('user_logged_out'),
	    XLink('user_just_visitor'),
	]),
    );
    return @res;
}

1;
