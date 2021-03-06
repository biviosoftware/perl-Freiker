# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::YearBaseList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub LOAD_ALL_SIZE {
    return 10_000;
}

sub find_row_by_date {
    return shift->find_row_by('Ride.ride_date', shift);
}

# sub internal_prepare_statement {
#     my($self, $stmt) = @_;
#     $stmt->where(
# 	$stmt->GTE(
# 	    'Ride.ride_date', [Freiker::Biz->current_school_year_start_date]),
# 	$stmt->LTE(
# 	    'Ride.ride_date', [Freiker::Biz->current_school_year_end_date]),
#     );
#     return shift->SUPER::internal_prepare_statement(@_);
# }

1;
