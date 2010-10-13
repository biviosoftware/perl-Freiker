# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolClassListForm;
use strict;
use Bivio::Base 'Biz.ExpandableListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub MUST_BE_SPECIFIED_FIELDS {
    return [
	'RealmOwner.display_name',
	'SchoolClass.school_grade',
    ];
}

sub ROW_INCREMENT {
    return 10;
}

sub WANT_EXECUTE_OK_ROW_DISPATCH {
    return 1;
}

sub execute_ok_row_create {
    my($self) = @_;
    my($sy) = $self->get_list_model->get_school_year;
    my($values) = $self->get_model_properties('SchoolClass');
    delete($values->{school_class_id});
    $self->new_other('SchoolClass')->create_realm(
	{
	    map(($_ => $sy->get($_)), qw(club_id school_year_id)),
	    %$values,
	},
	$self->get_model_properties('RealmOwner'),
    );
    return;
}

sub execute_ok_row_delete {
    my($self) = @_;
    $self->get_list_model->get_model('SchoolClass')->cascade_delete;
    return;
}

sub execute_ok_row_update {
    my($self) = @_;
    $self->update_model_properties('SchoolClass');
    $self->update_model_properties('RealmOwner');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'SchoolClassList',
	require_context => 1,
	visible => [
	    $self->field_decl([
		'RealmOwner.display_name',
		'SchoolClass.school_grade',
	    ], {in_list => 1}),
	],
	other => [
	    [qw(SchoolClass.school_class_id RealmOwner.realm_id)],
	],
    });
}

sub internal_initialize_list {
    my($self) = @_;
    my($sy) = $self->new_other('SchoolYear');
    $sy->create_this_year_unless_exists;
#TODO: Copy in last year's classes
    $self->new_other('SchoolClassList')->load_with_school_year($sy);
    return shift->SUPER::internal_initialize_list(@_);
}
	
1;
