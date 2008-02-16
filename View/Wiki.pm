# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Wiki;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub edit {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(WikiForm => [
	'WikiForm.RealmFile.path_lc',
	$self->HIDE_IS_PUBLIC ? () : 'WikiForm.RealmFile.is_public',
	Join([
	    FormFieldError({
		field => 'content',
		label => 'text',
	    }),
	    TextArea({
		field => 'content',
		rows => 30,
		cols => 80,
	    }),
	]),
    ]));
}

sub view {
    my(@res) = shift->SUPER::view(@_);
    view_unsafe_put(
	xhtml_byline => If(
	    ['->can_user_execute_task', 'FORUM_WIKI_EDIT'],
	    vs_text_as_prose('wiki_view_byline'),
	),
    );
    return @res;
}

1;
