# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::RealmType;
use strict;
$Freiker::Delegate::RealmType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Delegate::RealmType::VERSION;

=head1 NAME

Freiker::Delegate::RealmType - realm types

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Delegate::RealmType;

=cut

=head1 EXTENDS

L<Bivio::Delegate::RealmType>

=cut

use Bivio::Delegate::RealmType;
@Freiker::Delegate::RealmType::ISA = ('Bivio::Delegate::RealmType');

=head1 DESCRIPTION

C<Freiker::Delegate::RealmType>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
        @{$proto->SUPER::get_delegate_info},
        SCHOOL => [
            21,
            undef,
            'School',
        ],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
