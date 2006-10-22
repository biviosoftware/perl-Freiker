# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
use base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($AUTOLOAD);

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

sub vs_learn_more {
    shift;
    return Link('[learn more]', shift, 'learn_more');
}

sub vs_main_img {
    my(undef, $img) = @_;
    return Tag(div => '', "index_$img", {tag_if_empty => 1});
}

sub vs_prose {
    my(undef, $prose) = @_;
    return DIV_prose(Prose($prose));
}

1;
