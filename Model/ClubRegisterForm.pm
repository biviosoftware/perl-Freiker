# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRegisterForm;
use strict;
use Bivio::Base 'Model.OrganizationInfoForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_L) = b_use('Type.Location');

sub execute_empty {
    my($self) = @_;
    my($res) = shift->SUPER::execute_empty(@_);
    $self->internal_put_field(
	'SchoolContact.display_name' => $self->req(qw(auth_user display_name)),
	'SchoolContact.email' => $self->new_other('Email')->unauth_load_or_die({
	    realm_id => $self->req('auth_user_id'),
	    location => $_L->get_default,
	})->get('email'),
    );
    return $res;
}

sub execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::execute_ok(@_);
    $self->internal_catch_field_constraint_error(
	club_name => sub {
	    my(undef, $ro) = $self->new_other('Club')->create_realm(
		$self->req('auth_user_id'),
		$self->get('club_name'),
		$self->get_model_properties('Address'),
		$self->get_model_properties('Website'),
		$self->get('club_size'),
	    );
	    $self->req
		->with_realm(
		    $ro,
		    sub {
			$self->get_field_type('time_zone_selector')
			    ->row_tag_replace(
				$self->get('time_zone_selector'),
				$self->req,
			    );
			return;
		    },
		);
	    $self->create_model_properties('SchoolContact', {
		club_id => $ro->get('realm_id'),
	    });
	    return;
	},
    );
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    $self->field_decl([
		[qw(club_name RealmOwner.display_name)],
		[qw(club_size ClubSize)],
                [qw(time_zone_selector TimeZoneSelector)],
	    ], undef, 'NOT_NULL'),
	    'SchoolContact.display_name',
	    'SchoolContact.email',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->new_other('TimeZoneList')->load_all;
    return @res;
}

sub validate {
    my($self) = @_;
    b_use('Model.UserSettingsListForm')->validate_time_zone_selector($self);
    return shift->SUPER::validate(@_);
}

1;
