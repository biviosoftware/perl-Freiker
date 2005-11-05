# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Ride;
use strict;
$Freiker::Model::Ride::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::Ride::VERSION;

=head1 NAME

Freiker::Model::Ride - a ride by a freiker

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::Ride;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Freiker::Model::Ride::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Freiker::Model::Ride>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'ride_t',
	columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            ride_date => ['Date', 'PRIMARY_KEY'],
        },
	auth_id => 'user_id',
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
