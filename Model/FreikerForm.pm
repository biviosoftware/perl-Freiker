# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerForm;
use strict;
use Bivio::Base 'Model.FreikerCodeForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_G_UNKNOWN) = b_use('Type.Gender')->UNKNOWN;
my($_FREIKER) = b_use('Auth.Role')->FREIKER;

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    $self->internal_put_field('User.gender' => $_G_UNKNOWN);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my(@res) = shift->SUPER::execute_ok(@_);
    return if $self->in_error;
    $self->internal_put_field('User.birth_date' =>
        $_D->date_from_parts(1, 1, $self->get('birth_year')));
    my($u) = $self->get_model('User')
	->update($self->get_model_properties('User'));
    $self->new_other('RealmUser')->create({
	realm_id => $req->get('auth_id'),
	user_id => $u->get('user_id'),
        role => $_FREIKER,
    });
    $u->get_model('RealmOwner')->update({
	display_name => $u->get('first_name'),
    });
    return @res;
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
	    'User.gender',
	],
	other => [
	    'User.birth_date',
	    [qw(FreikerCode.user_id User.user_id)],
	],
    });
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    $self->validate_address;
    return;
}

1;
