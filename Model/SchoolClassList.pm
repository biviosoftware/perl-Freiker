# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolClassList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SY) = b_use('Model.SchoolYear');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_UNSPECIFIED_VALUE) = b_use('Type.PrimaryId')->UNSPECIFIED_VALUE;

sub find_by_teacher_name {
    my($self, $teacher_name) = @_;
    return $self->find_row_by(teacher_name_lc => lc($teacher_name));
}

sub find_row_by_id {
    my($self, $id) = @_;
    return $self->find_row_by('SchoolClass.school_class_id', $id);
}

sub get_school_year {
    return shift->[$_IDI];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => [[qw(SchoolClass.school_class_id RealmOwner.realm_id)]],
	order_by => [qw(
	    SchoolClass.school_grade
	    RealmOwner.display_name
	)],
	other => [
	    $self->field_decl([
		[qw(display_name DisplayName)],
		[qw(teacher_name_lc DisplayName)],
	    ]),
	],
	auth_id => 'SchoolClass.club_id',
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($sg) = $row->{'SchoolClass.school_grade'};
    $row->{display_name}
	= ($sg ? $sg->get_short_desc . ' ' : '')
	. $row->{'RealmOwner.display_name'};
    $row->{teacher_name_lc} = lc($row->{'RealmOwner.display_name'});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($sy) = $self->get_school_year;
    $stmt->where(
	map([
	    'SchoolClass.school_year_id',
	    [$sy ? $sy->get('school_year_id') : $_UNSPECIFIED_VALUE],
	# SECURITY: Although this could be an unauth_load, the club_id
	#           check is the only thing that makes sense.
        ], qw(school_year_id club_id)),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub load_with_school_year {
    my($self, $school_year) = @_;
    $self->[$_IDI] = $school_year
	|| $self->new_other('SchoolYear')->create_this_year_unless_exists;
    return $self->load_all;
}

1;
