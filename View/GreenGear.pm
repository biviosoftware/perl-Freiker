# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::GreenGear;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
	    CLUB_FREIKER_LIST
	    GREEN_GEAR_FORM
	)]),
	body => vs_paged_list(GreenGearList => [
	    'GreenGear.begin_date',
	    'GreenGear.end_date',
	    'RealmOwner.display_name',
	    'freiker_codes',
	    'ride_count',
	    'parent_display_name',
	    'parent_email',
	]),
    );
}

sub form {
    return shift->internal_put_base_attr(
	tools => TaskMenu([qw(
	    CLUB_FREIKER_LIST
	    GREEN_GEAR_LIST
	)]),
	body => vs_simple_form(GreenGearForm => [
	    'GreenGearForm.GreenGear.begin_date',
	    'GreenGearForm.GreenGear.end_date',
	    'GreenGearForm.GreenGear.must_be_registered',
	    'GreenGearForm.GreenGear.must_be_unique',
	]),
    );
}

1;

