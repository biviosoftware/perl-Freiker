# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::DistanceList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [{
	    name => 'distance',
	    # Type just has to be the right decimals
	    type => 'Miles',
	    constraint => 'NOT_NULL',
	}],
	other_query_keys => [qw(in_miles)],
    });
}

sub internal_load_rows {
    my($self) = @_;
    return [reverse(map(
	+{distance => $_},
	$self->get_query->unsafe_get('in_miles') ? (.5, 1, 1.5, 2, 2.5) : (1, 2),
	3..20,
    ))];
}

1;
