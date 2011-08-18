# Copyright (c) 2006-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
use Bivio::Base 'UIXHTML.ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub vs_freiker_list_actions {
    my($proto, $which, $model) = @_;
    return {
	column_heading => String($proto->vs_text("$model.list_actions")),
	column_data_class => 'list_actions',
	column_widget => ListActions([
	    map(
		[
		    $proto->vs_text("$model.list_action.$_"),
		    $_,
		    URI({
			task_id => $_,
			query => {
			    'ListQuery.parent_id' => ['RealmUser.user_id'],
			},
			no_context => 1,
		    }),
		],
		map(
		    "${which}_$_",
		    qw(
			FREIKER_RIDE_LIST
			MANUAL_RIDE_FORM
			FREIKER_CODE_ADD
			FREIKER_EDIT
		    ),
		),
	    ),
	]),
    };
}

sub vs_freiker_list_selector {
    my($proto, $fields) = @_;
    $fields ||= [qw(fr_begin fr_end fr_trips fr_registered fr_current)];
    my($f) = b_use('Model.FreikerListQueryForm');
    return (
	selector => Join([
	    Form($f->simple_package_name, Join([
                FormErrorList(),
		map(
		    (
			$_ eq 'fr_year' ? Select({
			    %{$f->get_select_attrs($_)},
			    class => 'element',
			})
                        : $_ eq 'fr_begin' ? (FormFieldLabel({
                            label => SPAN_label('Dates: '),
                            field => $_,
                        }),
			DateField({
                            form_model => [$f->package_name],
			    event_handler => DateYearHandler(),
                            field =>  $_,
                        }))
                        : $_ eq 'fr_end' ? (
			    FormFieldLabel({
				label => SPAN_label(' To: '),
				field => $_,
			    }),
			    DateField({
				form_model => [$f->package_name],
				field =>  $_,
				event_handler => DateYearHandler(),
			    }),
			)
                        : Checkbox({
			    field => $_,
			}),
			' ',
		    ),
		    @$fields,
		),
		FormButton('ok_button')->put(label => $proto->vs_text(
		    $f->simple_package_name, 'ok_button')),
	    ])),
	]),
    );
}

sub vs_gears_email {
    return String([['->req'], '->format_email', shift->vs_text('support_email')]);
}

sub vs_prize_list {
    my(undef, $list, $uri_args) = @_;
    return vs_list($list => [
	{
	    field => 'Prize.name',
	    column_widget => Link(
		Join([
		    Image(['->image_uri'], {
			alt_text => ['Prize.name'],
			class => 'in_list',
		    }),
		    SPAN_name(String(['Prize.name'], {hard_newlines => 0})),
		    ' provided by ',
		    String(['RealmOwner.display_name']),
		    ' for ',
		    SPAN_rides(
			If(['->has_keys', 'PrizeRideCount.ride_count'],
			   ['PrizeRideCount.ride_count'],
			   ['Prize.ride_count'])),
		    ' trips ',
		    SPAN_desc(WikiText(['Prize.description'])),
		]),
		$uri_args ? ['->format_uri', @$uri_args]
		    : ['Prize.detail_uri'],
	    ),
	},
    ], {
	class => 'prizes list',
	show_headings => 0,
    });
}

sub vs_wheel_contact {
    return Join([q{please contact us at }, shift->vs_gears_email()]);
}

1;
