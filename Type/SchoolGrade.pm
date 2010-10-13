# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::SchoolGrade;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => 0,
    G_PRE => [-2, 'PreK', 'Preschool'],
    G_K => [-1, 'KG', 'Kindergarten'],
    G_1 => [1, '1st', 'First Grade',],
    G_2 => [2, '2nd', 'Second Grade'],
    G_3 => [3, '3rd', 'Third Grade'],
    G_4 => [4, '4th', 'Fourth Grade'],
    G_5 => [5, '5th', 'Fifth Grade'],
    G_6 => [6, '6th', 'Sixth Grade'],
    G_7 => [7, '7th', 'Seventh Grade'],
    G_8 => [8, '8th', 'Eigth Grade'],
    G_9 => [9, '9th', 'Ninth Grade'],
    G_10 => [10, '10th', 'Tenth Grade'],
    G_11 => [11, '11th', 'Eleventh Grade'],
    G_12 => [12, '12th', 'Twelfth Grade'],
]);

1;
