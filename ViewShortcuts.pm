# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Freiker::ViewShortcuts;
use strict;
$Freiker::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::ViewShortcuts::VERSION;

=head1 NAME

Freiker::ViewShortcuts - view convenience methods

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Freiker::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::ViewShortcuts>

=cut

use Bivio::UI::HTML::ViewShortcuts;
@Freiker::ViewShortcuts::ISA = ('Bivio::UI::HTML::ViewShortcuts');

=head1 DESCRIPTION

C<Freiker::ViewShortcuts>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_site_name"></a>

=head2 vs_site_name() : array_ref

Returns a widget value that 

=cut

sub vs_site_name {
    return shift->vs_text('site_name');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
