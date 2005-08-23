# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Test::Freiker;
use strict;
$Freiker::Test::Freiker::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Test::Freiker::VERSION;

=head1 NAME

Freiker::Test::Freiker - Test functions

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Test::Freiker;

=cut

=head1 EXTENDS

L<Bivio::Test::Language::HTTP>

=cut

use Bivio::Test::Language::HTTP;
@Freiker::Test::Freiker::ISA = ('Bivio::Test::Language::HTTP');

=head1 DESCRIPTION

C<Freiker::Test::Freiker>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
