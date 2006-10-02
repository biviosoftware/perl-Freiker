# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Biz;
use strict;
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');
my($_YEAR) = $_D->now_as_year - ($_D->get_part($_D->now, 'month') < 6 ? 1 : 0);
my($_START_DATE) = $_D->date_from_parts_or_die(1, 8, $_YEAR);
my($_END_DATE) = $_D->date_from_parts_or_die(31, 7, $_YEAR + 1);

sub current_school_year {
    return $_YEAR;
}

sub current_school_year_start_date {
    return $_START_DATE;
}

sub current_school_year_end_date {
    return $_END_DATE;
}

1;
