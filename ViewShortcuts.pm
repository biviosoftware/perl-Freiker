# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
use base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($AUTOLOAD);
my($_WT) = Bivio::Type->get_instance('WikiText');

sub vs_barcode_ride_link {
    my($self, $field) = @_;
    return [$field, {
	column_widget => Link(
	    String([['->get_list_model'], $field]),
	    [sub {
		 return {
		     task_id => 'WHEEL_BARCODE_RIDE_LIST',
		     query => {
			 'ListQuery.parent_id' => $_[1],
		     },
		 };
	     }, [['->get_list_model'], $field]],
	),
    }];
}

sub vs_base_menu {
    my($proto, $values) = @_;
    return Join(
	[map($proto->vs_link(@$_), @$values)],
	{join_separator => Image('heart_9', {class => 'sep'})},
    );
}

sub vs_email {
    my(undef, $name, $host) = @_;
    return SPAN_email(
	Join([
	    $name || die('name must be supplied'),
	    Image('at'),
	    $host || ['Bivio::UI::Facade', 'mail_host'],
	]),
    );
}

sub vs_gears_email {
    return shift->vs_email('gears');
}

sub vs_gears_contact {
    return Join([q{please contact us at }, shift->vs_gears_email()]);
}

sub vs_learn_more {
    shift;
    return Link('[learn more]', shift, 'learn_more');
}

sub vs_main_img {
    my(undef, $img) = @_;
    return Tag(div => '', "index_$img", {tag_if_empty => 1});
}

sub vs_prize_list {
    my(undef, $list, $uri_args) = @_;
    return vs_list($list => [
	{
	    field => 'Prize.name',
	    column_widget => Link(
		Join([
		    Image(['->image_uri'], {
			alt_text => ['Prize.name'],
			class => 'in_list',
		    }),
		    SPAN_name(String(["Prize.name"], {hard_newlines => 0})),
		    ' for ',
		    SPAN_rides(['Prize.ride_count']),
		    ' rides &mdash; ',
		    SPAN_desc([sub {
			my($req) = shift->get_request;
			return $_WT->render_html(shift(@_), undef, $req);
		    }, ["Prize.description"]]),
		]),
		['->format_uri', @$uri_args],
	    ),
	},
    ], {
	class => 'prizes list',
	show_headings => 0,
    });
}

sub vs_prose {
    my(undef, $prose) = @_;
    return DIV_prose(Prose($prose));
}

sub vs_wheel_contact {
    return Join([q{please contact us at }, shift->vs_gears_email()]);
}

1;
