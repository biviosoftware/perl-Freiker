# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::FacadeComponent::Task;
use strict;
use Bivio::Base 'FacadeComponent';


sub parse_uri {
    my($self, $uri) = (shift, shift);
    $uri = '/go/site/' . (
	$1 eq 'index' ? 'wiki/Home'
	: $1 eq 'press/20060506' ? 'wiki/Press_06May2006'
	: $1 eq 'donate' ? 'donate'
	: ('wiki/' . ucfirst($1))
    ) if $uri =~ m{^/+hm/+(.+)$};
    return $self->SUPER::parse_uri($uri, @_);
}

1;
