# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SchoolClassListHandler;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_JS) = b_use('HTMLWidget.JavaScript');

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onchange="refresh_list(this, \''
	. $source->req('form_model')
	    ->get_field_name_for_html('refresh_class_list')
	. '\')"';
}

sub render {
    my($self, $source, $buffer) = @_;
    return $_JS->render($source, $buffer, $self->package_name, <<'EOF');
function refresh_list(element, field_name) {
    document.getElementsByName(field_name)[0].value = true;
    element.form.submit();
}
EOF
}

1;
