# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerClassListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PI) = b_use('Type.PrimaryId');

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field('new_school_class_id' => _get_class_id($self));
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
    return
	if $_PI->is_equal(my $curr_id = _get_class_id($self),
			  my $new_id = $self->get('new_school_class_id'));
    my($ru) = $self->new_other('RealmUser')->set_ephemeral;
    my($uid) = $self->get('RealmUser.user_id');
    $ru->unauth_delete_freiker($curr_id, $uid)
	if $curr_id;
    $ru->create_freiker_unless_exists($uid, $new_id)
	if $new_id;
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
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->new_other('SchoolClassList')->load_with_school_year;
    return @res;
}

sub _get_class_id {
    my($self) = @_;
    return $self->new_other('RealmUser')->set_ephemeral
	->unsafe_school_class_for_freiker(
	    $self->get_list_model->get('RealmUser.user_id'));
}

1;
