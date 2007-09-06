# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Wiki;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub view {
    return shift->call_super_before(\@_, sub {
        view_unsafe_put(
	    xhtml_topic => '',
	    xhtml_byline => '',
	    xhtml_title => vs_text_as_prose('wiki_view_topic'),
	);
	return;
    });
}

1;
