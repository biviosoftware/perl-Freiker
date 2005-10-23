# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeListForm;
use strict;
use base ('Bivio::Biz::ListFormModel');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    $self->internal_put_field(
	'Class.class_id' => $lm->get('RealmUser_2.realm_id')
	    || $lm->EMPTY_KEY_VALUE);
    $self->internal_put_field('RealmOwner.display_name' =>
	$lm->get('RealmOwner.name') eq $lm->get('RealmOwner.display_name')
	    ? '' : $lm->get('RealmOwner.display_name'));
    return;
}

sub execute_ok_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    $self->new_other('FreikerInfoForm')->update(
	$lm->get('RealmUser.user_id'),
	$self->get('RealmOwner.display_name'),
	$self->get('Class.class_id'),
	$lm->get('RealmUser_2.realm_id'),
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	list_class => 'BarcodeList',
	visible => [
	    {
		name => 'Class.class_id',
		in_list => 1,
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'RealmOwner.display_name',
		in_list => 1,
		constraint => 'NONE',
	    },
	],
	primary_key => ['RealmOwner.name'],
    });
}

sub validate_row {
    my($self) = @_;
    return if $self->in_error;
    # Sanity check to be sure someone isn't hacking the form; any
    # error will do, since the only way to get this is with a hacked form
    $self->internal_put_error('Class.class_id' => 'NULL')
	unless $self->get_request->get('Model.ClassSelectList')->find_row_by_id(
	    $self->get('Class.class_id'),
	);
    return;
}

1;
