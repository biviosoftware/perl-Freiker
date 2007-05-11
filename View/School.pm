# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::School;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub freiker_list {
    return shift->internal_body(vs_list(ClubFreikerList => [
	'RealmOwner.display_name',
	'ride_count',
    ]));
}

sub register {
    return shift->internal_body(vs_simple_form(ClubRegisterForm => [qw{
	ClubRegisterForm.club_name
	ClubRegisterForm.ClubAux.club_size
	ClubRegisterForm.ClubAux.website
	ClubRegisterForm.Address.zip
    }]));
}

1;
