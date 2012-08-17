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
    if ($self->req('Type.FormMode')->eq_create) {
	$self->internal_put_field(
	    'SchoolContact.display_name' => $self->req(qw(auth_user display_name)),
	    'SchoolContact.email' => $self->new_other('Email')->unauth_load_or_die({
		realm_id => $self->req('auth_user_id'),
		location => $_L->get_default,
	    })->get('email'),
	);
    } else {
	map({
	    $self->load_from_model_properties($self->req("Model.$_"));
	} qw(Address SchoolContact Website));
	my($rt) = $self->new_other('RowTag');
	$self->internal_put_field(
	    club_name => $self->req(qw(auth_realm owner display_name)),
	    club_size => $rt->get_value('CLUB_SIZE'),
	    allow_tagless => $rt->get_value('ALLOW_TAGLESS') || 0,
	    time_zone_selector => $self->get_field_type('time_zone_selector')
		->row_tag_get($self->req),
	);
    }
    return $res;
}

sub execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::execute_ok(@_);
    if ($self->req('Type.FormMode')->eq_create) {
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
			    _update_row_tag($self, 'allow_tagless');
			    _update_time_zone($self);
			    return;
			},
		    );
		$self->create_model_properties('SchoolContact', {
		    club_id => $ro->get('realm_id'),
		});
		return;
	    },
	);
    } else {
	map({
	    $self->internal_put_field("$_.location" =>
		b_use("Model.$_")->DEFAULT_LOCATION)
		unless $_ eq 'SchoolContact';
	    $self->update_model_properties($_);
	} qw(Address SchoolContact Website));
	$self->new_other('RealmOwner')->load->update({
	    display_name => $self->get('club_name'),
	});
	map({
	    _update_row_tag($self, $_);
	} qw(club_size allow_tagless));
	_update_time_zone($self);
    }
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
		[qw(allow_tagless Boolean)],
	    ], undef, 'NOT_NULL'),
	    'SchoolContact.display_name',
	    'SchoolContact.email',
	],
	other => [qw(
	    Address.location
	    Website.location
	)],
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

sub _update_row_tag {
    my($self, $field) = @_;
    $self->new_other('RowTag')->replace_value(
	$self->req('auth_id'),
	uc($field),
	$self->get($field),
    );
    return;
}

sub _update_time_zone {
    my($self) = @_;
    $self->get_field_type('time_zone_selector')
	->row_tag_replace(
	    $self->get('time_zone_selector'),
	    $self->req,
	);
    return;
}

1;
