# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_D) = b_use('Type.Date');
my($_G_UNKNOWN) = b_use('Type.Gender')->UNKNOWN;
my($_FREIKER) = b_use('Auth.Role')->FREIKER;
my($_K) = b_use('Type.Kilometers');
my($_PI) = b_use('Type.PrimaryId');
my($_B) = b_use('Type.Boolean');
my($_RT) = b_use('Type.RideType');

sub execute_empty {
    my($self) = @_;
    my($uid) = $self->unsafe_get('FreikerCode.user_id');
    if ($uid) {
	$self->load_from_model_properties('User');
	my($d) = $self->get('User.birth_date');
	$self->internal_put_field(birth_year =>
	    $d ? $_D->get_parts($d, 'year') : undef);
	$self->internal_put_field(
	    'SchoolClass.school_class_id' => _current_class_id($self, $uid),
	    'has_graduated' => $self->new_other('RowTag')->set_ephemeral
		->row_tag_get($uid, 'HAS_GRADUATED'),
	);
	my($fi) = $self->new_other('FreikerInfo')->unauth_load_or_die({user_id => $uid});
	if (my $km = $fi->get('distance_kilometers')) {
	    $self->internal_put_field(
		kilometers => $km,
		miles => $_K->to_miles($km),
	    );
	}
	$self->internal_put_field('default_ride_type' =>
	    $_RT->row_tag_get($uid, $self->req));
    } else {
	$self->internal_put_field('User.gender' => $_G_UNKNOWN);
	$self->internal_put_field('has_graduated' => 0);
    }
    my($m) = $self->new_other('Address');
    $self->load_from_model_properties($m)
	if $uid
	&& $m->unauth_load({realm_id => $uid})
	&& $m->get('zip')
        || $self->get('in_parent_realm')
	&& $m->unauth_load({realm_id => $self->req('auth_id')});
    return shift->SUPER::execute_empty(@_);
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    _validate_school_class($self);
    return
	if $self->in_error;
    $self->internal_put_field('User.gender' => $_G_UNKNOWN)
	unless $self->unsafe_get('User.gender');
    my($uid) = $self->unsafe_get('FreikerCode.user_id');
    $self->update_school_class(
	undef,
	$uid,
	_current_class_id($self, $uid),
	$self->unsafe_get('SchoolClass.school_class_id'),
	$uid && $self->new_other('RowTag')->set_ephemeral
	    ->row_tag_get($uid, 'HAS_GRADUATED'),
	$self->unsafe_get('has_graduated'),
    );
    if (my $by = $self->unsafe_get('birth_year')) {
	$self->internal_put_field(
	    'User.birth_date' => $_D->date_from_parts(1, 1, $by));
    }
    $self->update_model_properties('User');
    $self->unauth_create_or_update_model_properties('Address');
    $self->internal_put_field(
	'FreikerInfo.distance_kilometers' => $self->get('in_miles')
	    ? $_K->from_miles($self->get('miles')) : $self->get('kilometers'));
    $self->unauth_create_or_update_model_properties('FreikerInfo');
    $_RT->row_tag_replace($uid, $self->get('default_ride_type'), $self->req);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
        visible => [
	    'User.first_name',
	    'User.middle_name',
	    'User.last_name',
	    {
		name => 'birth_year',
		type => 'Year',
		constraint => 'NONE',
	    },
	    {
		name => 'default_ride_type',
		type => 'RideType',
		constraint => 'NOT_NULL',
	    },
	    $self->field_decl([
		[qw(kilometers Kilometers)],
		[qw(miles Miles)],
		'SchoolClass.school_class_id',
		[qw(has_graduated Boolean)],
		'Address.street1',
		'Address.street2',
		'Address.city',
		'Address.state',
		'Address.zip',
		'User.gender',
	    ]),
	],
	other => [
	    $self->field_decl(
		[
		    'in_parent_realm',
 		    'allow_club_id',
		    'in_miles',
		    'curr_has_graduated',
		],
		'Boolean',
	    ),
	    'curr.SchoolClass.school_class_id',
	    'User.birth_date',
	    [qw(FreikerCode.user_id User.user_id FreikerInfo.user_id Address.realm_id)],
	    'Address.country',
	    'FreikerInfo.distance_kilometers',
	],
    });
}

sub internal_load_class_list {
    my($self, $club_id) = @_;
    return $self->req->with_realm(
	$club_id,
	sub {
	    return $self->new_other('SchoolClassList')->load_with_school_year;
	},
    );
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    my($frl) = $self->ureq('Model.FreikerRideList');
    $self->internal_put_field(
	'FreikerCode.user_id' => my $uid = $frl && $frl->get_user_id);
    my($in_parent_realm) = $self->req(qw(auth_realm type))->eq_user;
    my($m) = $self->new_other('Address');
    # Prior to adding CA, US users didn't necessarily have addresses
    my($country) = $m->unsafe_load ? $m->get('country') : 'US';
    $self->internal_put_field(
	'Address.country' => $country,
	in_miles => _is_us($country),
 	allow_club_id => $in_parent_realm,
	in_parent_realm => $in_parent_realm,
    );
    $uid
 	? $self->req->with_realm(
 	    $self->new_other('RealmUser')->club_id_for_freiker($uid),
 	    sub {
 		$self->new_other('SchoolClassList')->load_with_school_year;
 	    },
 	)
	: $in_parent_realm
	    ? ()
	    : $self->new_other('SchoolClassList')->load_with_school_year;
    return @res;
}

sub update_school_class {
    my($self, $model, $uid, $curr_cid, $new_cid, $curr_grad, $new_grad) = @_;
    $self ||= $model;
    unless (!defined($new_grad) || $_B->is_equal($curr_grad, $new_grad)) {
	$self->new_other('RowTag')->set_ephemeral->row_tag_replace(
	    $uid,
	    'HAS_GRADUATED',
	    $new_grad,
	);
	if ($curr_cid && $new_grad) {
	    $self->new_other('RealmUser')->set_ephemeral
		->unauth_delete_freiker($curr_cid, $uid);
	    return;
	}
    }
    return
	if $new_grad || $_PI->is_equal($curr_cid, $new_cid);
    my($ru) = $self->new_other('RealmUser');
    $ru->unauth_delete_freiker($curr_cid, $uid)
	if $curr_cid;
    $ru->create_freiker_unless_exists($uid, $new_cid)
	if $new_cid;
    return;
}

sub validate {
    my($self) = @_;
    b_use('Model.UserSettingsListForm')->validate_user_names($self);
    $self->validate_not_null($self->unsafe_get('in_miles') ? 'miles' : 'kilometers');
    return
	unless $self->in_error;
    $self->validate_address;
    return;
}

sub validate_address {
    my($self, $model) = @_;
    $model ||= $self;
    $model->validate_not_null('Address.country');
    $model->validate_not_null('Address.zip');
    return
	if $model->in_error;
    my($cc, $zip) = $model->get(qw(Address.country Address.zip));
    my($v, $e) = _country_zip($model, $cc)->from_literal($zip);
    if ($v) {
	$model->internal_put_field('Address.zip' => $v);
    }
    else {
	$model->internal_put_error('Address.zip' => $e);
    }
    return;
}

sub _country_zip {
    my($model, $cc) = @_;
    return _is_us($cc) ? b_use('Type.USZipCode')
	: $model->get_field_type('Address.zip');
}

sub _current_class_id {
    my($self, $uid) = @_;
    return $uid && $self->new_other('RealmUser')
	->unsafe_school_class_for_freiker($uid);
}

sub _is_us {
    return (shift || '') eq 'US' ? 1 : 0;
}

sub _class_list_for_code {
    my($self) = @_;
    return $self->internal_load_class_list(
	$self->new_other('RealmUser')->club_id_for_freiker(
	    $self->get('FreikerCode.user_id'),
	),
    );
}

sub _validate_school_class {
    my($self) = @_;
    return
	unless my $scid = $self->unsafe_get('SchoolClass.school_class_id');
    $self->internal_put_error('SchoolClass.school_class_id' => 'NOT_FOUND')
	unless _class_list_for_code($self)->find_row_by_id($scid);
    return;
}

1;
