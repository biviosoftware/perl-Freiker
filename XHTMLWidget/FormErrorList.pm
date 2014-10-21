# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::FormErrorList;
use strict;
use Bivio::Base 'HTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_SA) = b_use('Type.StringArray');

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        tag => 'div',
        CLASS => 'b_main_errors',
        control => [['->ancestral_get', 'form_model'], '->in_error'],
        value => [sub {
           return join('', map('<p>'.$_.'</p>', @{$_SA->sort_unique([
               map($_->get_long_desc, values(%{$_[1]})),
           ])}));
        }, [['->ancestral_get', 'form_model'], '->get_errors']],
    );
    return shift->SUPER::initialize(@_);
}

1;
