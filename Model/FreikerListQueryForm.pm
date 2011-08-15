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
my($_RT) = b_use('Auth.RealmType');

sub execute_empty {
    my($self) = @_;
    return
	unless $self->req('task')->has_realm_type($_RT->CLUB);
    my($query) = $self->req('query');
    $query
	? $self->internal_put_field(
	    $query->{fr_trips} ? (fr_trips => 1) : (),
	    $query->{fr_registered} ? (fr_registered => 1) : (),
	    $query->{fr_all} ? (fr_all => 1) : (),
	    $query->{fr_begin} ? (fr_begin => $_D->from_literal($query->{fr_begin})) : (),
	    $query->{fr_end} ? (fr_end => $_D->from_literal($query->{fr_end})) : (),
	    $query->{fr_year} ? (fr_year => $_YQ->from_literal($query->{fr_year})) : (),
	) : $self->internal_put_field(
	    fr_trips => 1,
	    fr_begin => $_YQ->get_default->first_date_of_school_year,
	    fr_end => $_D->now,
	);
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
        : ($_B->from_literal($v))[0];
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(fr_all Boolean)],
	[qw(fr_registered Boolean)],
	[qw(fr_trips TripsQuery)],
	[qw(fr_year YearQuery)],
        [qw(fr_begin Date)],
        [qw(fr_end Date)],
    ];
}

1;
