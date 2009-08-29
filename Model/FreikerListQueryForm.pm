# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerListQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub filter_keys {
    return [qr{^fr_\w+$}, @{shift->SUPER::filter_keys(@_)}];
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(fr_registered Boolean)],
	[qw(fr_trips TripsQuery)],
	[qw(fr_year YearQuery)],
    ];
}

1;
