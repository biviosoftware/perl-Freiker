# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::FacadeComponent::Task;
use strict;
use Bivio::Base 'FacadeComponent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub parse_uri {
    my($self, $uri) = (shift, shift);
    $uri = '/go/site/wiki/' . (
	$1 eq 'index' ? 'Home'
	: $1 eq 'press/20060506' ? 'Press_06May2006'
	: ucfirst($1)
    ) if $uri =~ m{^/+hm/+(.+)$};
    return $self->SUPER::parse_uri($uri, @_);
}

1;
