# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Delegate::TypeError;
use strict;
$Freiker::Delegate::TypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Delegate::TypeError::VERSION;

=head1 NAME

Freiker::Delegate::TypeError - additional type errors

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Delegate::TypeError;

=cut

use Bivio::Delegate::SimpleTypeError;
@Freiker::Delegate::TypeError::ISA = ('Bivio::Delegate::SimpleTypeError');

=head1 DESCRIPTION

C<Freiker::Delegate::TypeError>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the type error declarations.

=cut

sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	YOUR_ERROR_HERE => [
	    501,
	    undef,
	    'Your error description here.',
	],
    ];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
