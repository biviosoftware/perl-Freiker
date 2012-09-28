# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerListQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_YQ) = b_use('Type.YearQuery');
my($_B) = b_use('Type.Boolean');
my($_D) = b_use('Type.Date');
my($_PI) = b_use('Type.PrimaryId');
my($_RT) = b_use('Type.RideType');

sub execute_empty {
    my($self) = shift;
    $self->SUPER::execute_empty(@_);
    my($tid) = $self->req('task')->get('id');
    return
	unless $tid->equals_by_name(qw(
	    CLUB_FREIKER_LIST
	    CLUB_SUMMARY_BY_CLASS_LIST
	    ADM_SUMMARY_BY_SCHOOL_LIST
	 ));
    my($query) = $self->req('query');
    $self->internal_put_field(
	fr_trips => 1,
	fr_begin => $_YQ->get_default->first_date_of_school_year,
	fr_end => $_D->now,
	fr_current => 1,
    ) unless grep($_ =~ /^fr_/, keys(%$query));
    return;
}

sub filter_keys {
    return [qr{^fr_\w+$}, @{shift->SUPER::filter_keys(@_)}];
}

sub get_value_fr {
    my($proto, $list, $which) = @_;
    return undef
	unless my $v = $list->ureq('Model.FreikerListQueryForm', $which)
	|| $list->get_query->unsafe_get($which);
    return $which eq 'fr_year' ? $_YQ->unsafe_from_any($v)
	: $which =~ /^fr_(?:begin|end)/ ? ($_D->from_literal($v))[0]
	: $which eq 'fr_type' ? $_RT->unsafe_from_any($v)
        : ($_B->from_literal($v))[0];
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(fr_all Boolean)],
	[qw(fr_registered Boolean)],
	[qw(fr_current Boolean)],
	[qw(fr_trips TripsQuery)],
	[qw(fr_year YearQuery)],
        [qw(fr_begin Date)],
        [qw(fr_end Date)],
        [qw(fr_type RideType)],
    ];
}

1;
