# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Freiker;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_YQ) = b_use('Type.YearQuery');
my($_D) = b_use('Type.Date');
my($_MRLF) = b_use('Model.ManualRideListForm');

sub code_form {
    return _form(shift, 'FreikerCodeForm');
}

sub form {
    return _form(shift, 'FreikerForm');
}

sub ride_list {
    return shift->internal_put_base_attr(
	tools => [sub {
	    my($which) = shift->req('task_id')->get_name =~ /^([a-z]+)/i;
	    return TaskMenu([
		map(+{
		    task_id => $_,
		    query => {
			'ListQuery.parent_id' => [[qw(Model.FreikerRideList ->get_query)], 'parent_id'],
		    },
		}, "${which}_MANUAL_RIDE_LIST_FORM"),
		{
		    task_id => "${which}_FREIKER_LIST",
		    label => "back_to_$which",
		    query => undef,
		},
	    ]),
	}],
	body => vs_paged_list(FreikerRideList => [
	    'Ride.ride_date',
	    'Ride.ride_type',
	]),
    );
}

sub manual_ride_form {
    return shift->internal_body(vs_simple_form(ManualRideForm => [
	['ManualRideForm.Ride.ride_date', {
	    want_picker => 1,
	    form_model => [b_use('Model.ManualRideForm')->package_name],
	    start_date => $_YQ->get_default->first_date_of_school_year,
	    end_date => $_D->local_today,
	}],
    ]));
}

sub manual_ride_list_form {
    return shift->internal_body(
	vs_list_form(ManualRideListForm => [
	    ['Ride.ride_date', {
		want_picker => 1,
		form_model => [b_use('Model.ManualRideListForm')->package_name],
		start_date => $_YQ->get_default->first_date_of_school_year,
		end_date => $_D->local_today,
		allow_undef => 1,
	    }],
	    ['Ride.ride_type', {
		wf_want_select => 1,
		enum_sort => 'as_int',
		event_handler => SameModeSelectHandler(),
	    }],
	    ['use_type_for_all', {
		column_heading => '',
		column_widget => If(['!',
		    [[qw(->req Model.ManualRideListForm)],
		        '->get_list_model'], '->get_cursor'],
		    SameModeCheckbox({
			field => 'use_type_for_all',
			label => vs_text(
			    'ManualRideListForm.use_type_for_all'),
			event_handler => SameModeCheckboxHandler(),
		    }),
		),
	    }],
	    #TODO: must be a better way to do the row_controls here
	    [String(' ', {
		row_control => [qw(->ureq Model.ManualRideListForm sibling_id0)],
	    })],
	    [Prose(vs_text('ManualRideListForm.prose.also_siblings'), {
		row_control => [qw(->ureq Model.ManualRideListForm sibling_id0)],
	    })],
	    map({
		["ManualRideListForm.sibling$_", {
		    row_control => [qw(->ureq Model.ManualRideListForm), "sibling_id$_"],
		}],
	    } (0 .. $_MRLF->LAST_OTHER)),
	    '*ok_button cancel_button',
	], undef, 1),
    );
}

sub _form {
    my($self, $model) = @_;
    return $self->internal_body(vs_simple_form($model => [
	$model eq 'FreikerForm' ? () : (
	    [
		FormFieldLabel({
		    field => 'freiker_code',
		    label => Join([
			vs_text("$model.FreikerCode.freiker_code"),
			':',
		    ]),
		}),
		Join([
		    FormField("$model.FreikerCode.freiker_code"),
		    Join([
			'&nbsp;&nbsp;',
			Checkbox('no_freiker_code'),
		    ], {
			control => And(
			    [qw(->ureq Model.FreikerCodeForm allow_tagless)],
			    [qw(! ->ureq Model.FreikerRideList)],
			),
		    }),
		]),
	    ],
	    ["$model.Club.club_id" => {
		wf_class => 'Select',
		choices => ['Model.ClubList'],
		list_id_field => 'Club.club_id',
		list_display_field => 'RealmOwner.display_name',
		unknown_label => vs_text('ClubList.unknown_label'),
		row_control => ["Model.$model", 'allow_club_id'],
		event_handler => SchoolClassListHandler(),
	    }],
	),
	["$model.SchoolClass.school_class_id" => {
	    wf_class => 'Select',
	    choices => ['Model.SchoolClassList'],
	    list_id_field => 'SchoolClass.school_class_id',
	    list_display_field => 'display_name',
	    unknown_label => vs_text('SchoolClassList.unknown_label'),
	    row_control => And(
		If([qw(->ureq Model.SchoolClassList)], 1, 0),
		[qw(Model.SchoolClassList ->get_result_set_size)],
	    ),
	}],
	$model eq 'FreikerForm' ? (
	    ["$model.has_graduated" => {
		wf_class => 'YesNo',
	    }],
	) : (),
	"$model.User.first_name",
	"$model.User.last_name",
	"$model.Address.zip",
	map(
	    ["$model.$_", {
		row_control => [$_ eq 'kilometers' ? '!' : (), "Model.$model", 'in_miles'],
	    }],
	    qw(miles kilometers),
	),
	["$model.default_ride_type" => {
	    wf_want_select => 1,
	    enum_sort => 'as_int',
	}],
	'-optional_address',
	"$model.Address.street1",
	"$model.Address.street2",
	"$model.Address.city",
	"$model.Address.state",
	'-optional_statistics',
	"$model.birth_year",
        ["$model.User.gender", {class => "radio_grid"}],
    ]));
}

1;
