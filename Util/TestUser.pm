# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::TestUser;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub init_adm {
    my($self) = @_;
    shift->SUPER::init_adm(@_);
    $self->req->with_realm(
	$self->ADM,
	sub {
	    $self->model('Address')->create({
		zip => Freiker::Test->ZIP,
		country => 'US',
	    });
	    return;
	},
    );
    return;
}

1;
