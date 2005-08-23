# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::School;
use strict;
$Freiker::Model::School::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::School::VERSION;

=head1 NAME

Freiker::Model::School - realm

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::School;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Freiker::Model::School::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Freiker::Model::School>

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
    return {
        version => 1,
	table_name => 'school_t',
	columns => {
            school_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    website => ['HTTPURI', 'NOT_NULL'],
        },
	auth_id => 'school_id',
    };
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
