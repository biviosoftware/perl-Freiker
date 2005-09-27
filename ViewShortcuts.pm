# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
$Freiker::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::ViewShortcuts::VERSION;

=head1 NAME

Freiker::ViewShortcuts - view convenience methods

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Freiker::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::ViewShortcuts>

=cut

use Bivio::UI::HTML::ViewShortcuts;
@Freiker::ViewShortcuts::ISA = ('Bivio::UI::HTML::ViewShortcuts');

=head1 DESCRIPTION

C<Freiker::ViewShortcuts>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_gears_email"></a>

=head2 static vs_gears_email() : Bivio::UI::Widget

=cut

sub vs_gears_email {
    my($proto) = @_;
    return $proto->vs_call(
	'Tag', span => $proto->vs_call('Join', [
	    'gears',
	    $proto->vs_call('Image', 'at'),
	    ['Bivio::UI::Facade', 'mail_host']]),
	'email');
}

=for html <a name="vs_learn_more"></a>

=head2 static vs_learn_more(string link) : Bivio::UI::Widget

Creates a learn more link.

=cut

sub vs_learn_more {
    return shift->vs_call('Link', '[learn more]', shift, 'learn_more');
}


=for html <a name="vs_acknowledgement"></a>

=head2 static vs_acknowledgement() : Bivio::UI::Widget

=head2 static vs_acknowledgement(boolean die_if_not_found) : Bivio::UI::Widget

Display acknowledgement, if it exists or can be extracted.  Sets row_control on
the widget.  Dies if die_if_not_found is specified and the acknowledgement is
missing (does not extract_label in this case).

=cut

sub vs_acknowledgement {
    my($proto, $die_if_not_found) = @_;
    return $proto->vs_call(
	'If',
	[sub {
	     return Bivio::Biz::Action->get_instance('Acknowledgement')
		 ->extract_label(shift->get_request);
	}],
	$proto->vs_call(
	    'Tag',
	    'p',
	    [sub {
		 my($req) = shift->get_request;
		 return __PACKAGE__->vs_call(
		     'String',
		     __PACKAGE__->vs_call(
			 'Prose',
			 Bivio::UI::Text->get_value(
			     'acknowledgement',
			     $req->get_nested(
				 'Action.Acknowledgement', 'label'),
			     $req,
			 ),
		     ),
		 );
	     }],
	    'ak',
	),
    );
}

=for html <a name="vs_descriptive_field"></a>

=head2 static vs_descriptive_field(any field) : array_ref

Calls vs_form_field and adds I<description> to the result.  I<description>
is an optional string, widget value, or widget.  It is always wrapped
in a String with font form_field_description.

=cut

sub vs_descriptive_field {
    my($proto, $field) = @_;
    my($name, $attrs) = ref($field) ? @$field : $field;
    my($label, $input) = $proto->vs_form_field($name, $attrs);
    return [
	$label->put(cell_class => 'lb'),
	$proto->vs_call(
	    'Join',
	    [
		$input,
		[sub {
		     my($req) = shift->get_request;
		     my($proto, $name) = @_;
#TODO: Need to create a separate space for field_descriptions so we don't
#      default to something that we don't expect.
		     my($v) = $req->get_nested('Bivio::UI::Facade', 'Text')
			 ->unsafe_get_value($name, 'field_description');
		     return $v ?
			 $proto->vs_call(
			     'Join', [
				 '<br />',
				 $proto->vs_call(
				     'Tag', 'p',
				     $proto->vs_call('Prose', $v),
				     'ds',
				 ),
			     ],
			 ) :  '';
		 }, $proto, $name],
	    ], {
		cell_class => 'in',
	    },
	),
    ];
}

=for html <a name="vs_base_menu"></a>

=head2 static vs_base_menu(array_ref values)

=cut

sub vs_base_menu {
    my($proto, $values) = @_;
    return $proto->vs_call(
	Join => [map($proto->vs_link(@$_), @$values)],
	{
	    join_separator => $proto->vs_call(
		Image => heart_9 => '', {class => 'sp'},
	    ),
	}
    );
}

=for html <a name="vs_simple_form"></a>

=head2 static vs_simple_form(string form_name, array_ref rows) : Bivio::UI::Widget

Creates a Form in a Grid.  I<rows> may be a field name, a separator name
(preceded by a dash), a widget (iwc colspan will be set to 2), or a list of
button names separated by spaces (preceded by a '*').  If there is no '*'
list, then StandardSubmit will be appended to the list of fields.

=cut

sub vs_simple_form {
    my($proto, $form, $rows) = @_;
    my($have_submit) = 0;
    return $proto->vs_call('Form', $form,
	$proto->vs_call('Grid', [
	    map({
		my($x);
		if (UNIVERSAL::isa($_, 'Bivio::UI::Widget')) {
		    $_->get_if_exists_else_put(cell_align => 'left'),
		    $x = [$_->put(cell_colspan => 2)];
		}
		elsif ($_ =~ s/^-//) {
		    $x = [$proto->vs_call(
			'String',
			$proto->vs_text('separator', $_),
			0,
			{
			    cell_colspan => 2,
			    cell_class => 'sp',
			},
		    )];
		}
		elsif ($_ =~ s/^\*//) {
		    $have_submit = 1;
		    $x = [$proto->vs_call(
			'StandardSubmit',
			{
			    cell_colspan => 2,
			    cell_align => 'center',
			    cell_class => 'sb',
			    $_ ? (buttons => [split(/\s+/, $_)]) : (),
			},
		    )];
		}
		elsif (ref($_) eq 'ARRAY' && ref($_->[0])) {
		    $x = $_;
		}
		else {
		    $x = $proto->vs_descriptive_field($_);
		}
		$x;
	    } @$rows),
	    $have_submit ? () : [$proto->vs_call('StandardSubmit', {
		cell_colspan => 2,
		cell_align => 'center',
		cell_class => 'sb',
	    })],
	], {
	    class => 'fr',
	    pad => 2,
	}));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
