# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Freiker;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
		}, "${which}_MANUAL_RIDE_FORM"),
		{
		    task_id => "${which}_FREIKER_LIST",
		    label => "back_to_$which",
		    query => undef,
		},
	    ]),
	}],
	body => vs_paged_list(FreikerRideList => [
	    'Ride.ride_date',
	]),
    );
}

sub manual_ride_form {
    return shift->internal_body(vs_simple_form(ManualRideForm => [qw{
        ManualRideForm.Ride.ride_date
    }]));
}

sub _form {
    my($self, $model) = @_;
    return $self->internal_body(vs_simple_form($model => [
	$model eq 'FreikerForm' ? () : (
	    "$model.FreikerCode.freiker_code",
	    ["$model.Club.club_id" => {
		wf_class => 'Select',
		choices => ['Model.ClubList'],
		list_id_field => 'Club.club_id',
		list_display_field => 'RealmOwner.display_name',
		unknown_label => 'Select School',
		row_control => ["Model.$model", 'allow_club_id'],
	    }],
	),
	"$model.User.first_name",
	"$model.Address.zip",
	map(
	    ["$model.$_", {
		row_control => [$_ eq 'kilometers' ? '!' : (), "Model.$model", 'in_miles'],
	    }],
	    qw(miles kilometers),
	),
	"-optional",
	"$model.birth_year",
        ["$model.User.gender", {class => "radio_grid"}],
    ]));
}

1;
