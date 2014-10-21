# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerClassListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

my($_PI) = b_use('Type.PrimaryId');
my($_B) = b_use('Type.Boolean');
my($_FF) = b_use('Model.FreikerForm');

sub execute_empty_row {
    my($self) = @_;
    my($g) = $self->new_other('RowTag')->set_ephemeral
	    ->row_tag_get($self->get('RealmUser.user_id'), 'HAS_GRADUATED');
    $self->internal_put_field(
	'new_school_class_id' => _get_class_id($self),
	'has_graduated' => $g,
	'new_has_graduated' => $g,
    );
    return;
}

sub execute_ok_end {
    my($self) = @_;
    return {
	carry_query => 1,
    };
}

sub execute_ok_row {
    my($self) = @_;
    my($uid) = $self->get('RealmUser.user_id');
    $_FF->update_school_class(
	$self,
	$uid,
	_get_class_id($self),
	$self->get('new_school_class_id'),
	$self->new_other('RowTag')->set_ephemeral
	    ->row_tag_get($uid, 'HAS_GRADUATED'),
	$self->get('new_has_graduated'),
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'ClubFreikerList',
	visible => [
	    {
		name => 'new_school_class_id',
		type => 'PrimaryId',
		constraint => 'NONE',
		in_list => 1,
	    },
	    {
		name => 'has_graduated',
		type => 'Boolean',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	    {
		name => 'new_has_graduated',
		type => 'Boolean',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
    });
}

sub internal_initialize_list {
    my($self) = shift;
    $self->new_other('SchoolClassList')->load_with_school_year;
    return $self->SUPER::internal_initialize_list(@_);
}

sub _get_class_id {
    my($self) = @_;
    return $self->new_other('RealmUser')->set_ephemeral
	->unsafe_school_class_for_freiker(
	    $self->get_list_model->get('RealmUser.user_id'));
}

1;
