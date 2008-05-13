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
			map(+{
			    task_id => $_,,
			    realm => vs_constant('site_adm_realm_name'),
			}, qw(SITE_ADM_USER_LIST SITE_ADM_SUBSTITUTE_USER)),
			'ADM_FREIKOMETER_LIST',
			'ADM_PRIZE_LIST',
			'ADM_PRIZE_COUPON_LIST',
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
			map(+{
			    task_id => 'MERCHANT_PRIZE_LIST',
			    label => String($_->{'RealmOwner.display_name'}),
			    realm => $_->{'RealmOwner.name'},
			    query => undef,
			}, sort {
			    $a->{'RealmOwner.display_name'}
				cmp $b->{'RealmOwner.display_name'}
			} @{$req->map_user_realms(
			    undef,
			    {
				'RealmOwner.realm_type' => Bivio::Auth::RealmType->MERCHANT,
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
		   Join([
		       DIV_login(Join([RoundedBox(
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
			    ),
		       ), DIV_sandbag1('', {tag_if_empty => 1})])),
		       DIV_sandbag2('', {tag_if_empty => 1}),
		   ]),
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
		    DIV('Please Donate'),
		    DIV_subtitle('even $10 helps!'),
		]),
		URI({
		    realm => vs_constant('site_realm_name'),
		    task_id => 'PAYPAL_FORM',
		    query => undef,
		}),
	    ),
	),
	xhtml_footer_middle => Join([
	    TaskMenu([
		'GENERAL_CONTACT',
		{
		    task_id => 'PAYPAL_FORM',
		    realm => vs_constant('site_realm_name'),
		    query => undef,
		},
		'SITE_ROOT',
		XLink('user_logged_out'),
		XLink('user_just_visitor'),
	    ]),
	    DIV_tag_line('Saving our society, one bike ride at a time.&#153;'),
	]),
    );
    return @res;
}

1;
