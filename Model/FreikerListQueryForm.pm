# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerListQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub execute_empty {
    my($self) = @_;
    my($begin) = $self->ureq(qw(query fr_begin));
    my($end) = $self->ureq(qw(query fr_end));
    $self->internal_put_field(
        $begin ? (fr_begin => $_D->from_literal_or_die($begin)) : (),
        $end ? (fr_end => $_D->from_literal_or_die($end)) : (),
    );
    return;
}

sub filter_keys {
    return [qr{^fr_\w+$}, @{shift->SUPER::filter_keys(@_)}];
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(fr_registered Boolean)],
	[qw(fr_trips TripsQuery)],
	[qw(fr_year YearQuery)],
        [qw(fr_begin Date)],
        [qw(fr_end Date)],
    ];
}

1;
