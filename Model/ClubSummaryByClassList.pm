# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubSummaryByClassList;
use strict;
use Bivio::Base 'Model.AdmSummaryBySchoolList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub FIELDS {
    return qw(class_realm_id
	      class_display_name);
}

sub RIDE_MODEL {
    return 'ClubRideList';
}

1;
