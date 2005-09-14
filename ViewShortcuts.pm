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

=for html <a name="vs_learn_more"></a>

=head2 static vs_learn_more(string link) : Bivio::UI::Widget

Creates a learn more link.

=cut

sub vs_learn_more {
    return shift->vs_call('Link', '[learn more]', shift, 'learn_more');
}

=for html <a name="vs_descriptive_field"></a>

=head2 static vs_descriptive_field(string field) : array_ref

Calls vs_form_field and adds I<description> to the result.  I<description>
is an optional string, widget value, or widget.  It is always wrapped
in a String with font form_field_description.

=cut

sub vs_descriptive_field {
    my($proto, $field) = @_;
    my($label, $input) = $proto->vs_form_field($field);
    return [
	$label,
	$proto->vs_call('Join', [
	    $input,
	    [sub {
		 my($req) = shift->get_request;
		 my($proto, $field) = @_;
#TODO: Need to create a separate space for field_descriptions so we don't
#      default to something that we don't expect.
		 my($v) = $req->get_nested('Bivio::UI::Facade', 'Text')
		     ->unsafe_get_value($field, 'field_description');
		 return $v ?
		     $proto->vs_call(
			 'String',
			 $proto->vs_call('Prose', '<br><p class="form_field_description">' . $v . '</p>'),
			 'form_field_description',
		     ) :  '';
	    }, $proto, $field],
	]),
    ];
}

=for html <a name="vs_simple_form"></a>

=head2 static vs_simple_form(string form_name, array_ref fields, Bivio::UI::Widget prologue, Bivio::UI::Widget epilogue) : Bivio::UI::Widget

Creates a Form in a Grid.  Prologue text.

=cut

sub vs_simple_form {
    my($proto, $form, $fields, $prologue, $epilogue) = @_;
    return $proto->vs_call('Form', $form,
	$proto->vs_call('Grid', [
	    $prologue ? (
		[$prologue->put(
		    cell_colspan => 2,
		    cell_align => 'left',
		    cell_class => 'form_prologue',
	        )],
#TODO: Remove when all apps updated
	    ) : (),
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
			    cell_class => 'separator',
			},
		    )];
		}
		elsif ($_ =~ s/^\*//) {
		    $x = [$proto->vs_call(
			'StandardSubmit',
			{
			    cell_colspan => 2,
			    cell_align => 'center',
			    cell_class => 'form_submit',
			    $_ ? (buttons => [split(/\s+/, $_)]) : (),
			},
		    )];
		}
		else {
		    $x = $proto->vs_descriptive_field($_);
		    $x->[0]->put(cell_class => 'form_field_label');
		    $x->[1]->put(cell_class => 'form_field_input');
		}
		$x;
	    } @$fields),
	    [$proto->vs_call('StandardSubmit', {
		cell_colspan => 2,
		cell_align => 'center',
		cell_class => 'form_submit',
	    })],
	    $epilogue ? (
		[$epilogue->put(
		    cell_colspan => 2,
		    cell_align => 'left',
		    cell_class => 'form_epilogue',
	        )],
	    ) : (),
	], {
	    pad => 2,
	}));
}

=for html <a name="vs_site_name"></a>

=head2 vs_site_name() : array_ref

Returns a widget value that 

=cut

sub vs_site_name {
    return shift->vs_text('site_name');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
