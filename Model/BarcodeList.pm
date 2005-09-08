# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeList;
use strict;
$Freiker::Model::BarcodeList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::BarcodeList::VERSION;

=head1 NAME

Freiker::Model::BarcodeList - list of barcodes

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::BarcodeList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Freiker::Model::BarcodeList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Freiker::Model::BarcodeList>

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
#TODO: 2006
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	order_by => [qw(
	    RealmOwner.name
	)],
	other => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
            [qw(RealmUser_2.realm_id)],
	],
	auth_id => ['RealmUser.realm_id'],
	primary_key => ['RealmOwner.name'],
	from => 'FROM realm_owner_t, realm_user_t'
	    . ' LEFT JOIN realm_user_t realm_user_t_2'
	    . ' ON (realm_user_t.user_id = realm_user_t_2.user_id'
	    . ' AND realm_user_t_2.role = '
	    . Bivio::Auth::Role->STUDENT->as_sql_param
	    . ')',
	where => [
	    'realm_user_t.role = ', Bivio::Auth::Role->FREIKER->as_sql_param,
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
