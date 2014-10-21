# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubSummaryByClassList;
use strict;
use Bivio::Base 'Model.AdmSummaryBySchoolList';


sub FIELDS {
    return qw(class_realm_id
	      class_display_name);
}

sub RIDE_MODEL {
    return 'ClubRideList';
}

1;
