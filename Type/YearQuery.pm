# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::YearQuery;
use strict;
use Bivio::Base 'Type.YearWindow';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DEFAULT) = _init(__PACKAGE__);

sub compile_short_desc {
    my($proto, $year) = @_;
    return "$year - " . ($year + 1);
}

sub first_date_of_school_year {
    my($self) = @_;
    return _first_date($self->as_int);
}

sub get_default {
    return $_DEFAULT;
}

sub _first_date {
    my($year) = @_;
    return $_D->date_from_parts(1, 8, $year);
}

sub _init {
    my($proto) = @_;
    my($year) = $_D->now_as_year;
    __PACKAGE__->compile(
	2005,
	$_D->compare($_D->now, _first_date($year)) >= 0 ? $year : $year - 1,
    );
    return __PACKAGE__->get_max;
}

1;
