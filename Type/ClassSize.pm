# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::ClassSize;
use strict;
$Freiker::Type::ClassSize::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Type::ClassSize::VERSION;

=head1 NAME

Freiker::Type::ClassSize - reasonable

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Type::ClassSize;

=cut

=head1 EXTENDS

L<Bivio::Type::Integer>

=cut

use Bivio::Type::Integer;
@Freiker::Type::ClassSize::ISA = ('Bivio::Type::Integer');

=head1 DESCRIPTION

C<Freiker::Type::ClassSize>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_max"></a>

=head2 static get_max() : int

Returns 99.

=cut

sub get_max {
    return 99;
}

=for html <a name="get_min"></a>

=head2 static get_min() : int

Returns 1

=cut

sub get_min {
    return 1;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
