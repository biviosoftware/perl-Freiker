# Copyright (c) 2006-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
use Bivio::Base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

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
		    SPAN_name(String(['Prize.name'], {hard_newlines => 0})),
		    ' provided by ',
		    String(['RealmOwner.display_name']),
		    ' for ',
		    SPAN_rides(
			If(['->has_keys', 'PrizeRideCount.ride_count'],
			   ['PrizeRideCount.ride_count'],
			   ['Prize.ride_count'])),
		    ' trips ',
		    SPAN_desc(WikiText(['Prize.description'])),
		]),
		$uri_args ? ['->format_uri', @$uri_args]
		    : ['Prize.detail_uri'],
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
