# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerClassListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PI) = b_use('Type.PrimaryId');
my($_B) = b_use('Type.Boolean');

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
	query => $self->req->get('query'),
    };
}

sub execute_ok_row {
    my($self) = @_;
    my($uid) = $self->get('RealmUser.user_id');
    my($curr_cid) = _get_class_id($self);
    my($ng) = $self->get('new_has_graduated');
    unless ($_B->is_equal(
	$self->new_other('RowTag')->set_ephemeral
	    ->row_tag_get($uid, 'HAS_GRADUATED'),
	$ng,
    )) {
	$self->new_other('RowTag')->set_ephemeral->row_tag_replace(
	    $uid,
	    'HAS_GRADUATED',
	    $self->get('new_has_graduated'),
	);
	if ($ng) {
	    $self->new_other('RealmUser')->set_ephemeral
		->unauth_delete_freiker($curr_cid, $uid);
	    return;
	}
    }
    return
	if $ng || $_PI->is_equal($curr_cid,
			  my $new_cid = $self->get('new_school_class_id'));
    my($ru) = $self->new_other('RealmUser')->set_ephemeral;
    $ru->unauth_delete_freiker($curr_cid, $uid)
	if $curr_cid;
    $ru->create_freiker_unless_exists($uid, $new_cid)
	if $new_cid;
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
    $self->new_other('ClubFreikerList')->load_page;
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
