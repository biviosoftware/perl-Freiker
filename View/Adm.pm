# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::Adm;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub freikometer_list {
    return shift->internal_body(
	vs_paged_list(AdmFreikometerList => [qw(
	    RealmOwner.name
	    RealmFile.modified_date_time
	)]),
    );

}

1;
