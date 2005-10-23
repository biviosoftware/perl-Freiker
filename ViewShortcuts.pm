# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
use base 'Bivio::UI::XHTML::ViewShortcuts';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub vs_gears_email {
    my($proto) = @_;
    return $proto->vs_call(
	'Tag', span => $proto->vs_call('Join', [
	    'gears',
	    $proto->vs_call('Image', 'at'),
	    ['Bivio::UI::Facade', 'mail_host']]),
	'email');
}

sub vs_learn_more {
    return shift->vs_call('Link', '[learn more]', shift, 'learn_more');
}

sub vs_base_menu {
    my($proto, $values) = @_;
    return $proto->vs_call(
	Join => [map($proto->vs_link(@$_), @$values)],
	{
	    join_separator => $proto->vs_call(
		Image => heart_9 => '', {class => 'sep'},
	    ),
	}
    );
}

1;
