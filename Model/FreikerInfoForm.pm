# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerInfoForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub EMPTY_NAME {
    return ' ';
}

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties('RealmOwner');
    my($r) = $self->new_other('RealmUser');
    $self->internal_put_field('Class.class_id' => _id($self));
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->update(
	$self->get_request->get('auth_id'),
	$self->get('RealmOwner.display_name', 'Class.class_id'),
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    ['Class.class_id', 'RealmUser.realm_id'],
	    'RealmOwner.display_name',
	],
	auth_id => [qw(RealmOwner.realm_id RealmUser.user_id)],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('ClassSelectList')->unauth_load_all({
	auth_id => $self->new_other('RealmUser')->unauth_load_or_die({
	    user_id => $self->get_request->get('auth_id'),
	    role => Bivio::Auth::Role->FREIKER,
	})->get('realm_id'),
    });
    return;
}

sub update {
    my($self, $user_id, $display_name, $new_class_id, $old_class_id) = @_;
    $self->new_other('RealmOwner')->unauth_load_or_die({
	realm_id => $user_id,
    })->update({
	display_name => $display_name || $self->EMPTY_NAME,
    });
    $old_class_id ||= _id($self);
    return if $new_class_id eq $old_class_id;
    my($ek) = $self->get_instance('ClassSelectList')->EMPTY_KEY_VALUE;
    my($ru) = $self->new_other('RealmUser');
    $ru->unauth_delete({
	realm_id => $old_class_id,
	user_id => $user_id,
	role => Bivio::Auth::Role->STUDENT,
    }) unless $ek eq $old_class_id;
    $ru->create({
	realm_id => $new_class_id,
	user_id => $user_id,
	role => Bivio::Auth::Role->STUDENT,
    }) unless $ek eq $new_class_id;
    return;
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    $self->internal_put_error('Class.class_id' => 'NULL')
	unless $self->get_request->get('Model.ClassSelectList')->find_row_by_id(
	    $self->get('Class.class_id'),
	);
    return;
}

sub _id {
    my($self) = @_;
    return $self->new_other('Class')
	->get_id_for_student($self->get_request->get('auth_id'))
	|| $self->get_instance('ClassSelectList')->EMPTY_KEY_VALUE;
}

1;
