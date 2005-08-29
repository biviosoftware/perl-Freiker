# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::ClassGrade;
use strict;
$Freiker::Type::ClassGrade::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Type::ClassGrade::VERSION;

=head1 NAME

Freiker::Type::ClassGrade - grades

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Type::ClassGrade;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Freiker::Type::ClassGrade::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Freiker::Type::ClassGrade>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    KINDERGARTEN_AM => [-3 => 'K am'],
    KINDERGARTEN_PM => [-2 => 'K pm'],
    KINDERGARTEN => [-1 => 'K'],
    UNKNOWN => [0 => 'Grade'],
    FIRST => [1 => '1st'],
    SECOND => [2 => '2nd'],
    THIRD => [3 => '3rd'],
    FOURTH => [4 => '4th'],
    FIFTH => [5 => '5th'],
    SIXTH => [6 => '6th'],
    SEVENTH => [7 => '7th'],
    EIGHTH => [8 => '8th'],
    NINTH => [9 => '9th'],
    TENTH => [10 => '10th'],
    ELEVENTH => [11 => '11th'],
    TWELFTH => [12 => '12th'],
]);

=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
