# Copyright (c) 2005-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Test::Freiker;
use strict;
use Bivio::Base 'TestLanguage.HTTP';


sub generate_image {
    my($self, $text) = @_;
    my($file) = $self->temp_file('image.jpg');
    $text =~ s/"/'/g;
    $text =~ s/\s+/ /sg;
    system(qq{convert -font helvetica -size 150x150 xc:white -fill blue -pointsize 36 -draw 'text 0,100 "$text"' $file}) == 0 || die;
    return $file;
}

sub get_test_now_as_date {
    my($self) = @_;
    return b_use('Type.Date')->from_datetime(b_use('Freiker.Test')->TEST_NOW);
}

sub handle_setup {
    my($self) = @_;
    shift->SUPER::handle_setup(@_);
    $self->home_page;
    $self->do_test_backdoor(TestData => 'reset_freikers');
    return;
}

sub nudge_test_now {
    my($self) = @_;
    $self->save_excursion(
	sub {$self->do_test_backdoor(TestData => 'nudge_test_now')});
    return;
}

sub register_random {
    my($self, $base) = @_;
    $self->home_page;
    $self->follow_link(qr{^register}i);
    my($z) = $self->random_integer(undef, 900000000);
    my($e) = $self->generate_local_email("$base-$z");
    $self->submit_form({
	name => "$base $z",
	email => $e,
	post => $z,
    });
    $self->visit_uri($self->verify_local_mail($e) =~ /(http:.+\?.+)/m);
    $self->submit_form({
	'^new' => 'password',
	enter => 'password',
    });
    return ($e, $z);
}

sub select_test_now {
    my($self) = @_;
    $self->submit_form(refresh => {
	_anon => '2008 - 2009',
    });
    return;
}

sub show_all_kids {
    my($self) = @_;
    $self->submit_form(Refresh => {
	trips => 0,
	registered => 0,
	current => 0,
	dates => '',
	to => '',
    });
    return;
}

1;
