# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::Gender;
use strict;
$Freiker::Type::Gender::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Type::Gender::VERSION;

=head1 NAME

Freiker::Type::Gender - use Mr. and Ms. instead of MALE or FEMALE

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Type::Gender;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Freiker::Type::Gender::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Freiker::Type::Gender>

=cut

#=IMPORTS
use Bivio::Type::Gender;

#=VARIABLES
__PACKAGE__->compile([
    map(
	($_->[0] => [Bivio::Type::Gender->from_name($_->[0])->as_int, $_->[1]]),
	[UNKNOWN => 'Title'],
	[FEMALE => 'Ms.'],
	[MALE => 'Mr.'],
    ),
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
