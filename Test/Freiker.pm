# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Test::Freiker;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base ('Bivio::Test::Language::HTTP');
use Freiker::Test;
use File::Temp ();

sub do_logout {
    my($self) = @_;
    $self->follow_link(qr{logout}i);
    return;
}

sub generate_image {
    my($self, $text) = @_;
    my(undef, $file) = $self->tmp_file('image.jpg');
    $text =~ s/"/'/g;
    $text =~ s/\S+/ /sg;
    system(qq{convert -size 150x150 xc:white -fill blue -pointsize 36 -draw 'text 0,100 "$text"' $file}) == 0 || die;
    return $file;
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

sub register_random {
    my($self, $base) = @_;
    $self->home_page;
    $self->follow_link(qr{^register}i);
    my($z) = $self->random_integer(undef, 90000_0000);
    my($e) = $self->generate_local_email("$base-$z");
    $self->submit_form({
	name => "$base $z",
	email => $e,
	zip => $z,
    });
    $self->visit_uri($self->verify_local_mail($e) =~ /(http:.+\?.+)/m);
    $self->submit_form({
	'^new' => 'password',
	enter => 'password',
    });
    return ($e, $z);
}

1;
