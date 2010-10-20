# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerListQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_YQ) = b_use('Type.YearQuery');
my($_B) = b_use('Type.Boolean');
my($_D) = b_use('Type.Date');

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
	[qw(fr_all TripsQuery)],
	[qw(fr_registered Boolean)],
	[qw(fr_trips TripsQuery)],
	[qw(fr_year YearQuery)],
        [qw(fr_begin Date)],
        [qw(fr_end Date)],
    ];
}

1;
