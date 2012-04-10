# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SameModeSelectHandler;
use strict;
use Bivio::Base 'Freiker::XHTMLWidget::SameModeCheckboxHandler';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onclick="same_mode_for_all(' .
	join(', ',
	     $source->get_field_name_for_html('use_type_for_all'),
	     'this',
	     $source->get_list_model->get_result_set_size,
	     'event',
	) . ')"';
}

1;
