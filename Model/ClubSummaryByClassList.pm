# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubSummaryByClassList;
use strict;
use Bivio::Base 'Model.AdmSummaryBySchoolList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');
my($_D) = b_use('Type.Date');
my($_FLQF) = b_use('Model.FreikerListQueryForm');

sub REALM_TYPE {
    return $_RT->SCHOOL_CLASS;
}

sub internal_get_summary {
    my($self, $realm_id) = @_;
    return $self->new_other('ClubFreikerClassList')->load_all({
	parent_id => $realm_id,
    })->get_summary;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	auth_id => 'SchoolClass.club_id',
        other => [
	    [qw(RealmOwner.realm_id SchoolClass.school_class_id)],
	    [qw(SchoolClass.school_year_id SchoolYear.school_year_id)],
	    'SchoolYear.start_date',
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($year_start) = $row->{'SchoolYear.start_date'};
    my($year_end) = $_D->add_years($year_start, 1);
    my($fr_begin) = $_FLQF->get_value_fr($self, 'fr_begin');
    my($fr_end) = $_FLQF->get_value_fr($self, 'fr_end');
    my($window_start, $window_end);
    if ($_D->compare_defined($fr_begin, $fr_end) < 0) {
	$window_start = $fr_begin;
	$window_end = $fr_end;
    } else {
	$window_start = $fr_end;
	$window_end = $fr_begin;
    }
    return 0
	if ($_D->compare_defined($year_start, $window_start) < 0
	    && $_D->compare_defined($year_end, $window_start) < 0)
	|| ($_D->compare_defined($year_start, $window_end) > 0
	    && $_D->compare_defined($year_end, $window_end) > 0);
    return 1;
}

1;
