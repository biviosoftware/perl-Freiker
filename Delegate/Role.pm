# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::Role;
use strict;
$Freiker::Delegate::Role::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Delegate::Role::VERSION;

=head1 NAME

Freiker::Delegate::Role - freiker, teacher, wheel

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Delegate::Role;

=cut

=head1 EXTENDS

L<Bivio::Delegate::Role>

=cut

use Bivio::Delegate::Role;
@Freiker::Delegate::Role::ISA = ('Bivio::Delegate::Role');

=head1 DESCRIPTION

C<Freiker::Delegate::Role>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info()

Add FREIKER, TEACHER, and WHEEL roles.

=cut

sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	WHEEL => [21],
	TEACHER => [22],
	FREIKER => [23],
	STUDENT => [24],
    ];
}

=for html <a name="is_admin"></a>

=head2 is_admin() : boolean

Returns true if WHEEL or SUPER::is_admin

=cut

sub is_admin {
    my($self) = shift;
    return $self->equals_by_name('WHEEL') || $self->SUPER::is_admin(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
