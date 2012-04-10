# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SameModeCheckbox;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Widget::Checkbox';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_want_multi_check_handler {
    return 0;
}

1;
