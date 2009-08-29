# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_G_UNKNOWN) = b_use('Type.Gender')->UNKNOWN;
my($_FREIKER) = b_use('Auth.Role')->FREIKER;
my($_K) = b_use('Type.Kilometers');

sub execute_empty {
    my($self) = @_;
    my($uid) = $self->unsafe_get('FreikerCode.user_id');
    if ($uid) {
	$self->load_from_model_properties('User');
	my($d) = $self->get('User.birth_date');
	$self->internal_put_field(birth_year =>
	    $d ? $_D->get_parts($d, 'year') : undef);
    }
    else {
	$self->internal_put_field('User.gender' => $_G_UNKNOWN);
    }
    my($m) = $self->new_other('Address');
    $self->load_from_model_properties($m)
	if $m->unauth_load({realm_id => $uid || $self->req('auth_id')});
    if (my $km = $m->unsafe_get('street2')) {
	$self->internal_put_field(
	    kilometers => $km,
	    miles => $_K->to_miles($km),
	);
    }
    return shift->SUPER::execute_empty(@_);
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    _update_address($self);
    $self->internal_put_field('User.birth_date' =>
        $_D->date_from_parts(1, 1, $self->get('birth_year')));
    my($u) = $self->get_model('User')
	->update($self->get_model_properties('User'));
    $u->get_model('RealmOwner')->update({
	display_name => $u->get('first_name'),
    });
    return {
	carry_query => 1,
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'User.first_name',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'birth_year',
		type => 'Year',
		constraint => 'NONE',
	    },
	    $self->field_decl([
		[qw(kilometers Kilometers)],
		[qw(miles Miles)],
		'Address.zip',
	    ], undef, 'NOT_NULL'),
	    'User.gender',
	],
	other => [
	    'User.birth_date',
	    [qw(FreikerCode.user_id User.user_id)],
	    $self->field_decl([[qw(in_miles Boolean)]]),
	    'Address.country',
	    'Address.street2',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    shift->SUPER::internal_pre_execute(@_);
    if (my $frl = $self->ureq('Model.FreikerRideList')) {
	$self->internal_put_field('FreikerCode.user_id' => $frl->get_user_id);
    }
    my($country) = $self->new_other('Address')
	->unauth_load_or_die({realm_id => $self->req('auth_id')})
	->get('country');
    $self->internal_put_field(
	'Address.country' => $country,
	in_miles => _is_us($country),
    );
    $self->new_other('DistanceList')
	->load_all({in_miles => $self->get('in_miles')});
    return;
}

sub validate {
    my($self) = @_;
    $self->internal_clear_error(
	$self->unsafe_get('in_miles') ? 'kilometers' : 'miles',
    );
    return
	unless $self->in_error;
    $self->validate_address;
    return;
}

sub validate_address {
    my($self, $model) = @_;
    $model ||= $self;
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
    return _is_us($cc) ? b_use('Type.USZipCode9')
	: $model->get_field_type('Address.zip');
}

sub _is_us {
    return (shift || '') eq 'US' ? 1 : 0;
}

sub _update_address {
    my($self, $new_uid) = @_;
    my($p) = $self->get_model_properties('Address');
    my($m) = $self->new_other('Address');
    $p->{realm_id} = $self->get('FreikerCode.user_id');
    $p->{street2} = $self->get('in_miles')
	? $_K->from_miles($self->get('miles')) : $self->get('kilometers');
    if ($m->unauth_load({realm_id => $p->{realm_id}})) {
	$m->update($p);
    }
    else {
	$m->create($p);
    }
    return;
}

1;
