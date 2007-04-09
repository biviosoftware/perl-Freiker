# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerForm;
use strict;
use Bivio::Base 'Model.FreikerCodeForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');
my($_G) = Bivio::Type->get_instance('Gender');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('User.gender' => $_G->UNKNOWN);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->internal_put_field(
	'User.birth_date' => $_D->date_from_parts(
	    1, 1, $self->get('birth_year')));
    my($uid) = ($self->new_other('User')->create_realm(
	$self->get_model_properties('User'),
	{},
    ))[0]->get('user_id');
    my($ru) = $self->new_other('RealmUser')->create({
	realm_id => $req->get('auth_id'),
	user_id => $uid,
        role => Bivio::Auth::Role->MEMBER,
    });
    $ru->create({
	realm_id => $self->get('Club.club_id'),
	user_id => $uid,
	role => Bivio::Auth::Role->MEMBER,
    });
    $self->internal_put_field('Ride.realm_id' => $uid);
    return shift->SUPER::execute_ok(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'User.first_name',
	    'FreikerCode.freiker_code',
	    'Club.club_id',
	    {
		name => 'birth_year',
		type => 'Year',
		constraint => 'NONE',
	    },
	    'User.gender',
	],
	other => [
	    'User.birth_date',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('ClubSelectList')->load_all;
    return;
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    my($req) = $self->get_request;
    my($l) = $req->get('Model.ClubSelectList');
    return $self->internal_put_error('Club.club_id' => 'NULL')
	if $l->EMPTY_KEY_VALUE eq $self->get('Club.club_id');
    return $self->internal_put_error('Club.club_id' => 'NOT_FOUND')
	unless $l->find_row_by_id($self->get('Club.club_id'));
    $self->internal_put_field(
	'FreikerCode.club_id' => $self->get('Club.club_id'));
    return shift->SUPER::validate(@_);
}

1;
