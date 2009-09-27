# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::TestUser;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self) = shift;
    my($res) = $self->SUPER::create(@_);
    $self->req->with_realm(
	$res,
	sub {
	    $self->model('Address')->create({
		zip => Freiker::Test->ZIP,
		country => 'US',
	    });
	    return;
	},
    );
    return $res;
}

1;
