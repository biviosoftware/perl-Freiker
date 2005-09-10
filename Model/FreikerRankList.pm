# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRankList;
use strict;
$Freiker::Model::FreikerRankList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::FreikerRankList::VERSION;

=head1 NAME

Freiker::Model::FreikerRankList - list of freikers at school and ranks

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::FreikerRankList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Freiker::Model::FreikerRankList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Freiker::Model::FreikerRankList>

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
	order_by => [
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => 'COUNT(*) as ride_count',
		sort_order => 1,
	    },
	    'RealmOwner.name',
        ],
	primary_key => [
	    ['RealmUser.user_id', 'Ride.user_id', 'RealmOwner.realm_id'],
	],
	other => [
	    {
		name => 'Ride.ride_date',
		in_select => 0,
	    },
	    {
		name => 'RealmUser.realm_id',
		in_select => 0,
	    },
	],
	auth_id => 'RealmUser.realm_id',
	where => [
	    'realm_user_t.role =', Bivio::Auth::Role->FREIKER->as_sql_param,
	],
	group_by => [
	    'RealmUser.user_id',
	    'RealmOwner.name',
	    'RealmUser.realm_id',
	    'RealmUser.role',
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