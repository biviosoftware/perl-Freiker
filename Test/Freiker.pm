# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Test::Freiker;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base ('Bivio::Test::Language::HTTP');
use Freiker::Test;

sub do_logout {
    return shift->visit_uri('/pub/logout');
}

sub login_as_wheel {
    my($self, $email) = @_;
    $self->home_page;
    $self->follow_link('wheel login');
    $self->submit_form(Login => {
	'Your Email:' => $email || Freiker::Test->WHEEL,
	'Password:' => Freiker::Test->PASSWORD,
    });
    return;
}

sub school_delete {
    my($self, $zip) = @_;
    return $self->do_test_backdoor(SchoolDeleteForm => {
	'Address.zip' => $zip,
    });
}

1;
