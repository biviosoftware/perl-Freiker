# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SameModeCheckboxHandler;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_JS) = b_use('Bivio::UI::HTML::Widget::JavaScript');

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onclick="same_mode_for_all(' .
	join(', ',
	     'this',
	     $source->get_field_name_for_html('Ride.ride_type'),
	     $source->get_list_model->get_result_set_size,
	     'event',
	) . ')"';
}

sub render {
    my($self, $source, $buffer) = @_;
    return $_JS->render($source, $buffer, $self->package_name, <<'EOF');
function same_mode_for_all(checkbox, select, rows, event) {
    var mode;
    if (checkbox.checked) {
        mode = checkbox.form[select.name.substr(0, select.name.indexOf('_') + 1) + '0'].value;
    }
    for (var i = 1; i < rows; i++) {
        var element = checkbox.form[select.name.substr(0, select.name.indexOf('_') + 1) + i];
        if (mode) {
            element.value = mode;
        }
        element.disabled = checkbox.checked;
    }
    return;
}
EOF
}

1;
