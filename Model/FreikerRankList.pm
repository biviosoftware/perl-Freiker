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

L<Freiker::Model::ClassList>

=cut

use Freiker::Model::ClassList;
@Freiker::Model::FreikerRankList::ISA = ('Freiker::Model::ClassList');

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
    return {
        version => 1,
	order_by => [
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => 'COUNT(*) as ride_count',
		sort_order => 0,
	    }, qw(
		RealmOwner.name
		RealmOwner.display_name
		Class.class_grade
		User.last_name
		User.first_name
	    )
        ],
	from => 'FROM ride_t, realm_owner_t, realm_user_t'
	    . ' LEFT JOIN realm_user_t realm_user_t_2'
	    . ' ON (realm_user_t.user_id = realm_user_t_2.user_id'
	    . ' AND realm_user_t_2.role = '
	    . Bivio::Auth::Role->STUDENT->as_sql_param
	    . ') LEFT JOIN class_t'
            . ' ON (realm_user_t_2.realm_id = class_t.class_id'
	    . ') LEFT JOIN realm_user_t realm_user_t_3'
            . ' ON (class_t.class_id = realm_user_t_3.realm_id'
	    . ' AND realm_user_t_3.role = '
	    . Bivio::Auth::Role->TEACHER->as_sql_param
	    . ') LEFT JOIN user_t'
            . ' ON (realm_user_t_3.user_id = user_t.user_id'
	    . ')',
	primary_key => [
	    ['RealmUser.user_id', 'Ride.user_id', 'RealmOwner.realm_id'],
	],
	other => [
	    {
		name => 'class_name',
		type => 'Name',
		constraint => 'NOT_NULL',
	    },
	    'User.gender',
	    map({
		{
		    name => $_,
		    in_select => 0,
		};
	    } qw(
		Ride.ride_date
		RealmUser.realm_id
		Class.class_id
		User.user_id
	    )),
	],
	auth_id => 'RealmUser.realm_id',
	where => [
	    'realm_user_t.role =', Bivio::Auth::Role->FREIKER->as_sql_param,
	],
	group_by => [qw(
	    RealmUser.user_id
	    RealmOwner.name
	    RealmOwner.display_name
	    RealmUser.realm_id
	    RealmUser.role
	    Class.class_grade
	    User.last_name
	    User.first_name
	    User.gender
	)],
    };
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
