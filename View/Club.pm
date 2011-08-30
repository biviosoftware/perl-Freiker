# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Club;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub freiker_by_teacher_list {
    my($self) = @_;
    return $self->internal_body_and_tools(
	vs_paged_list(FreikerByTeacherList => [
	    'User.first_name',
	    'FreikerInfo.distance_kilometers',
	    'SchoolClass.school_class_id',
	]),
    );
}

sub freiker_class_list_form {
    my($self) = @_;
    return $self->internal_body_and_tools(
	vs_simple_form('ClubFreikerClassListForm', [
	    vs_paged_list('ClubFreikerClassListForm', [
		['display_name', {
		    column_order_by => [qw(
			User.last_name_sort
			User.first_name_sort
			User.middle_name_sort
		    )],
		}],
		'freiker_codes',
		['class_display_name', {
		    column_order_by => ['school_class_display_name'],
		}],
		['new_school_class_id', {
		    wf_class => 'Select',
		    choices => ['Model.SchoolClassList'],
		    list_id_field => 'SchoolClass.school_class_id',
		    list_display_field => 'display_name',
		    unknown_label => 'Select Class',
		}],
		['has_graduated', {
		    column_data_class => 'centered_cell',
		    column_widget => Simple([sub {
			return shift->get('has_graduated')
			    ? vs_text('ClubFreikerList.has_graduated_true')
			    : vs_text('ClubFreikerList.has_graduated_false');
		    }]),
		}],
		['new_has_graduated', {
		    column_data_class => 'centered_cell',
		}],
	    ]),
	]),
    );
    return;
}

sub freiker_import_form {
    my($self) = @_;
    return shift->internal_body_and_tools(
	vs_simple_form(FreikerImportForm => [
	    'FreikerImportForm.source',
	]),
    );
}

sub freiker_list {
    my($self) = @_;
    $self->internal_put_base_attr(vs_freiker_list_selector());
    return $self->internal_body_and_tools(
	vs_paged_list(ClubFreikerList => [
	    ['display_name', {
		column_order_by => [qw(
		    User.last_name_sort
		    User.first_name_sort
		    User.middle_name_sort
		)],
	    }],
	    ['freiker_codes', {
		column_heading_class => 'narrow_heading',
	    }],
	    ['ride_count', {
		column_heading_class => 'narrow_heading',
	    }],
	    ['miles', {
		column_heading_class => 'narrow_heading',
		column_control => ['Model.ClubFreikerList', '->in_miles'],
	    }],
            ['FreikerInfo.distance_kilometers', {
		column_heading_class => 'narrow_heading',
		column_control => ['!', 'Model.ClubFreikerList', '->in_miles'],
	    }],
	    ['current_miles', {
		column_heading_class => 'narrow_heading',
	    }],
	    ['calories', {
		column_heading_class => 'narrow_heading',
	    }],
	    'class_display_name',
	    ['has_graduated', {
		column_heading_class => 'narrow_heading',
		column_data_class => 'centered_cell',
		column_widget => Simple([sub {
		    return shift->get('has_graduated')
			? vs_text('ClubFreikerList.has_graduated_true')
			: vs_text('ClubFreikerList.has_graduated_false');
		}]),
		column_control => ['!', 'Model.FreikerListQueryForm', 'fr_current'],
	    }],
	    vs_freiker_list_actions(qw(CLUB ClubFreikerList)),
	]),
	[
	    {
		task_id => 'CLUB_FREIKER_LIST_CSV',
		query => [qw(Model.FreikerListQueryForm ->get_current_query_for_list)],
	    },
	],
    );
}

sub freiker_list_csv {
    my($self) = @_;
    return shift->internal_body(CSV(ClubFreikerList => [
	qw(
	    User.last_name
	    User.first_name
	    User.middle_name
	    freiker_codes
	    ride_count
	    parent_first_name
	    parent_middle_name
	    parent_last_name
	    parent_zip
	    parent_email
	    FreikerInfo.distance_kilometers
	    miles
	    Address.street1
	    Address.street2
	    Address.city
	    Address.state
	    Address.zip
	    User.gender
	    birth_year
	    school_grade
	    school_class_display_name
        ),
    ]));

}

sub freiker_select {
    return shift->internal_body_and_tools(
	vs_simple_form(FreikerSelectForm => [qw(
            FreikerSelectForm.FreikerCode.freiker_code
	)]),
    );
}

sub internal_body_and_tools {
    my($proto, $body, $extra) = @_;
    return shift->internal_put_base_attr(
	body => $body,
	tools => TaskMenu([
	    @{$extra || []},
	    qw(
		CLUB_FREIKER_ADD
		CLUB_FREIKER_CODE_IMPORT
		CLUB_FREIKER_LIST
		CLUB_RIDE_DATE_LIST
		CLUB_RIDE_FILL_FORM
		GREEN_GEAR_FORM
		GREEN_GEAR_LIST
		CLUB_SCHOOL_CLASS_LIST_FORM
		CLUB_FREIKER_IMPORT_FORM
		CLUB_FREIKER_CLASS_LIST_FORM
	    ),
	], {
	    want_more_threshold => 2,
	    want_sorting => 1,
	}),
    );
}

sub manual_ride_form {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubManualRideForm => [
	    'ClubManualRideForm.add_days',
	]),
    );
}

sub prize {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubPrizeForm => [
	    'ClubPrizeForm.PrizeRideCount.ride_count',
	]),
    );
}

sub prize_confirm {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubPrizeConfirmForm => [qw(
	    ClubPrizeConfirmForm.Prize.name
	    ClubPrizeConfirmForm.PrizeRideCount.ride_count
	)]),
    );
}

sub prize_delete {
    return shift->internal_body_and_tools(
	vs_simple_form('ClubPrizeDeleteForm'),
    );
}

sub prize_coupon_list {
    return shift->internal_body_and_tools(
	vs_paged_list(ClubPrizeCouponList => [qw(
	    PrizeCoupon.creation_date_time
	    RealmOwner.display_name
	    family_display_name
	    freiker_codes
	    Prize.name
	), {
	    column_heading => String(vs_text("ClubPrizeCouponList.list_actions")),
	    column_widget => ListActions([
		[
		    vs_text('ClubPrizeCouponList.list_action.CLUB_FREIKER_PRIZE_DELETE'),
		    'CLUB_FREIKER_PRIZE_DELETE',
		    URI({
			task_id => 'CLUB_FREIKER_PRIZE_DELETE',
			query => [qw(->format_query THIS_DETAIL)],
			no_context => 1,
		    }),
		],
	    ], {
		column_data_class => 'list_actions',
	    }),
        }]),
    );
}

sub prize_list {
    return shift->internal_body_and_tools(
	vs_prize_list(ClubPrizeList => [qw(THIS_DETAIL CLUB_PRIZE)]),
    );
}

sub prize_select {
    return shift->internal_body_and_tools(
	vs_prize_list(ClubPrizeSelectList =>
	     [qw(THIS_DETAIL CLUB_FREIKER_PRIZE_CONFIRM)]),
	[
	    {
		task_id => 'CLUB_FREIKER_MANUAL_RIDE_FORM',
		query => {
		    'ListQuery.parent_id' => [qw(Model.ClubPrizeSelectList ->get_user_id)],
		},
	    },
	],
    );
}

sub register {
    return shift->internal_body(vs_simple_form(ClubRegisterForm => [qw{
	ClubRegisterForm.club_name
	ClubRegisterForm.club_size
	ClubRegisterForm.Website.url
	ClubRegisterForm.Address.street1
	ClubRegisterForm.Address.street2
	ClubRegisterForm.Address.city
	ClubRegisterForm.Address.state
	ClubRegisterForm.Address.zip
	ClubRegisterForm.Address.country
        ClubRegisterForm.time_zone_selector
    }]));
}

sub ride_date_list {
    return shift->internal_body_and_tools(
	vs_paged_list(ClubRideDateList => [
	    'Ride.ride_date',
	    'ride_count',
	]),
    );
}

sub ride_fill_form {
    return shift->internal_body_and_tools(
	vs_simple_form(ClubRideFillForm => [
	    'ClubRideFillForm.Ride.ride_date',
	]),
    );
}

sub school_class_list_form {
    return shift->internal_body_and_tools(
	vs_list_form(SchoolClassListForm => [
	    'SchoolClassListForm.RealmOwner.display_name',
	    {
		field => 'SchoolClass.school_grade',
		unknown_label => 'Select',
		enum_sort => 'as_int',
	    },
	]),
    );
}

1;
