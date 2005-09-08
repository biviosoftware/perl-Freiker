# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolRankList;
use strict;
$Freiker::Model::SchoolRankList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::SchoolRankList::VERSION;

=head1 NAME

Freiker::Model::SchoolRankList - schools

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::SchoolRankList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Freiker::Model::SchoolRankList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Freiker::Model::SchoolRankList>

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
	order_by => [qw(
	    RealmOwner.display_name
	    Address.zip
        )],
	primary_key => [[qw(RealmOwner.realm_id Address.realm_id)]],
	where => [
	    'realm_owner_t.realm_type = ',
	    Bivio::Auth::RealmType->SCHOOL->as_sql_param,
        ],
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
