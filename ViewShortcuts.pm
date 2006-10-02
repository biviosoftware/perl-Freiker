# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
use base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($AUTOLOAD);

sub vs_barcode_ride_link {
    my($self, $field) = @_;
    return [$field, {
	column_widget => Link(
	    String([['->get_list_model'], $field]),
	    [sub {
		 return {
		     task_id => 'WHEEL_BARCODE_RIDE_LIST',
		     query => {
			 'ListQuery.parent_id' => $_[1],
		     },
		 };
	     }, [['->get_list_model'], $field]],
	),
    }];
}

sub vs_base_menu {
    my($proto, $values) = @_;
    return Join(
	[map($proto->vs_link(@$_), @$values)],
	{join_separator => Image('heart_9', {class => 'sep'})},
    );
}

sub vs_email {
    my(undef, $name, $host) = @_;
    return SPAN_email(
	Join([
	    $name || die('name must be supplied'),
	    Image('at'),
	    $host || ['Bivio::UI::Facade', 'mail_host'],
	]),
    );
}

sub vs_gears_email {
    return shift->vs_email('gears');
}

sub vs_learn_more {
    shift;
    return Link('[learn more]', shift, 'learn_more');
}

sub vs_main_img {
    my(undef, $img) = @_;
    return Tag(div => '', "index_$img", {tag_if_empty => 1});
}

sub vs_prose {
    my(undef, $prose) = @_;
    return DIV_prose(Prose($prose));
}

#TODO: Remove after 10/15
sub vs_simple_form {
    my($proto, $form, $rows) = @_;
    my($have_submit) = 0;
    my($m) = Bivio::Biz::Model->get_instance($form);
    return Form(
	$form,
	Join([
	    $proto->vs_form_error_title($form),
	    Grid([
		map({
		    my($x);
		    if (UNIVERSAL::isa($_, 'Bivio::UI::Widget')
			&& $_->simple_package_name eq 'FormField'
		    ) {
			$_->put_unless_exists(cell_class => 'field'),
			$x = [
			    $proto->vs_call('Join', [''], {cell_class => 'label'}),
			    $_,
			];
		    }
		    elsif (UNIVERSAL::isa($_, 'Bivio::UI::Widget')) {
			$x = [$_->put_unless_exists(cell_colspan => 2)];
		    }
		    elsif ($_ =~ s/^-//) {
			$x = [String(
			    vs_text($form, 'separator', $_),
			    0,
			    {
				cell_colspan => 2,
				cell_class => 'sep',
			    },
			)];
		    }
		    elsif ($_ =~ s/^'//) {
			$x = [Prose(vs_text($form, 'prose', $_), {
			    cell_colspan => 2,
			    cell_class => 'form_prose',
			})];
		    }
		    elsif ($_ =~ s/^\*//) {
			$have_submit = 1;
			$x = [StandardSubmit(
			    {
				cell_colspan => 2,
				cell_class => 'submit',
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
		$have_submit ? () : [
		    StandardSubmit({
			cell_colspan => 2,
			cell_class => 'submit',
		    }),
		],
	    ], {
		class => 'simple',
	    }),
	]),
    );
}

1;
