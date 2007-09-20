# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::School;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ride_date_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
	    CLUB_FREIKER_LIST
	)]),
	body => vs_paged_list(ClubRideDateList => [
	    'Ride.ride_date',
	    'ride_count',
	]),
    );
}

sub freiker_list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
	    CLUB_RIDE_DATE_LIST
	)]),
	body => vs_paged_list(ClubFreikerList => [
	    'RealmOwner.display_name',
	    'ride_count',
	]),
    );
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
