# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::WidgetInjector;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Model.Ride');

sub public_total_trips_xhtml_widget {
    my($self) = @_;
    return shift->internal_body(
	String([[sub {$_R->count_all}], 'HTMLFormat.Amount', 0, 0, 0]),
    );
}

1;
