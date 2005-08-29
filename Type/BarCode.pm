# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::BarCode;
use strict;
$Freiker::Type::BarCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Type::BarCode::VERSION;

=head1 NAME

Freiker::Type::BarCode - bar code object

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Type::BarCode;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Freiker::Type::BarCode::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Freiker::Type::BarCode>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(any value) : array

Validates bar code.

=cut

sub from_literal {
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $v;
    return (undef, Bivio::TypeError->BAR_CODE)
	unless $v =~ /^[a-z]{1,3}\d{3,}/i;
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
    return length($curr) <= $proto->get_width - 3 ? $curr . '000'
	: Bivio::Die->die('out of bar codes');
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
