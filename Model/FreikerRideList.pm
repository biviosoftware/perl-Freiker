# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRideList;
use strict;
$Freiker::Model::FreikerRideList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::FreikerRideList::VERSION;

=head1 NAME

Freiker::Model::FreikerRideList - x

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::FreikerRideList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Freiker::Model::FreikerRideList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Freiker::Model::FreikerRideList>

=cut

#=IMPORTS

#=VARIABLES
my($_D) = Bivio::Type->get_instance('Date');

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
	want_select => 0,
	@{$self->internal_initialize_local_fields(
	    other => [
		[total => 'Integer'],
		[last_date => 'Date'],
	    ],
	    undef, 'NOT_NULL',
	)},
    });
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows()

=cut

sub internal_load_rows {
    my($self) = @_;
    return [
	{
	    total => Bivio::SQL::Connection->execute_one_row(
		'SELECT COUNT(*) FROM ride_t WHERE user_id = ?',
		[$self->get_request->get('auth_id')],
	    )->[0],
	    last_date => Bivio::SQL::Connection->execute_one_row(
		"SELECT @{[$_D->from_sql_value(q{MAX(ride_date)})]} FROM ride_t WHERE user_id = ?",
		[$self->get_request->get('auth_id')],
	    )->[0],
	    last_update => Bivio::SQL::Connection->execute_one_row(
		"SELECT @{[$_D->from_sql_value(q{MAX(ride_date)})]} FROM ride_t",
	    )->[0],
	},
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
