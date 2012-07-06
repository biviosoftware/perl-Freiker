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
	xhtml_header_left => undef,
	xhtml_header_right => vs_header_su_link(
	    Link(
		Image('logo'),
		URI({task_id => 'MY_SITE'}),
	    ),
	),
	xhtml_footer_left => undef,
	xhtml_footer_right => undef,
	xhtml_footer_center => Join([
	    _footer_bar(),
	    _footer_legal(),
	]),
    );
    return @res;
}

sub _footer_bar {
    return Grid(
	[[
	    DIV(
		q{Boltage&nbsp;&gt;&nbsp;&nbsp;&nbsp;Let's make it a way of life},
		{cell_class => 'footer_bar_left'},
	    ),
	    map(
		Link(
		    $_->[1],
		    URI({
			task_id => 'CLIENT_REDIRECT',
			query => {
			    b_use('Action.ClientRedirect')->QUERY_TAG
				=> 'http://www.facebook.com/pages/Boltage/10150154921405078?ref=ts',
			},
		    }),
		    {cell_class => "footer_bar_$_->[0]"},
		),
		[center => Simple('Find us on FaceBook')],
		[right => Image('social_fb')],
	    ),
	]],
	{class => 'footer_bar'},
    );
}

sub _footer_legal {
    return DIV_footer_legal(
	Join([
	    '&copy; 2010 KidCommute, Inc.',
	    map({
		(my $text = $_) =~ s/_/ /g;
		(
		    '&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;',
		    Link($text,
			 URI({
			     task_id => 'SITE_WIKI_VIEW',
			     path_info => $_,
			 }),
		    ),
		);
	    } qw(Privacy_Policy Terms_of_Service)),
	]),
    );
}

1;
