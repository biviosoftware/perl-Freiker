# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::Barcode;
use strict;
$Freiker::Type::Barcode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Type::Barcode::VERSION;

=head1 NAME

Freiker::Type::Barcode - bar code object

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Type::Barcode;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Freiker::Type::Barcode::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Freiker::Type::Barcode>

=cut


=head1 CONSTANTS

=cut

=for html <a name="REGEX"></a>

=head2 REGEX : regexp_ref

Returns regular expression that matches a barcode.

=cut

sub REGEX {
    return qr/([a-z]{1,3}\d{3})/i;
}

#=IMPORTS

#=VARIABLES
my($_SCHOOL_SUFFIX) = '000';

=head1 METHODS

=cut

=for html <a name="extract_school"></a>

=head2 static extract_school(string code) : string

Converts I<code> into a school code.

=cut

sub extract_school {
    my($proto, $code) = @_;
    $code = $proto->from_literal_or_die($code);
    return ($code =~ /(\D+)/)[0] . $_SCHOOL_SUFFIX;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(any value) : array

Validates bar code.

=cut

sub from_literal {
    my($proto) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $v;
    return (undef, Bivio::TypeError->BAR_CODE)
	unless $v =~ /^@{[$proto->REGEX]}$/i;
    return lc($v);
}

=for html <a name="get_max"></a>

=head2 static get_max() : string

Returns zzz999

=cut

sub get_max {
    return 'zzz999';
}

=for html <a name="get_min"></a>

=head2 static get_min() : string

Returns a000

=cut

sub get_min {
    return 'a000';
}

=for html <a name="get_width"></a>

=head2 static get_width() : int

Returns 6.

=cut

sub get_width {
    return 6;
}

=for html <a name="next_school"></a>

=head2 static next_school(string curr) : string

Increments the string for the next school.

=cut

sub next_school {
    my($proto) = shift;
    my($curr) = $proto->from_literal_or_die(@_);
    $curr =~ s/\d+//;
    $curr++;
    return length($curr) <= $proto->get_width - 3
	? $curr . $_SCHOOL_SUFFIX
	: Bivio::Die->die('out of bar codes');
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
