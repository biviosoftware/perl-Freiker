# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Test::Freiker;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base ('Bivio::Test::Language::HTTP');
use Freiker::Test;

sub do_logout {
    my($self) = @_;
    $self->follow_link(qr{logout}i);
    return;
}

sub login_as {
    my($self, $email) = @_;
    $self->home_page;
    $self->follow_link(qr{login}i);
    $self->submit_form(Login => {
	qr{Email}i => $email,
	qr{password}i => $self->default_password,
    });
    return;
}

1;
