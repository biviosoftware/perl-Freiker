# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SameModeSelectHandler;
use strict;
use Bivio::Base 'Bivio::UI::Widget';


sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    # only respond to select in the first row
    return ''
	unless $source->get_list_model->get_cursor == 0;
    return ' onclick="same_mode_for_all(' .
	join(', ',
	     $source->get_field_name_for_html('use_type_for_all'),
	     'this',
	     $source->get_list_model->get_result_set_size,
	     'event',
	) . ')"';
}

sub render {
    return;
}

1;
