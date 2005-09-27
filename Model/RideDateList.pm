# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RideDateList;
use strict;
$Freiker::Model::RideDateList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::RideDateList::VERSION;

=head1 NAME

Freiker::Model::RideDateList - x

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::RideDateList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Freiker::Model::RideDateList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Freiker::Model::RideDateList>

=cut


=head1 CONSTANTS

=cut

=for html <a name="PAGE_COUNT"></a>

=head2 PAGE_COUNT : int

Keep list small

=cut

sub PAGE_COUNT {
    return 50;
}

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
	order_by => ['Ride.ride_date'],
	primary_key => ['Ride.ride_date'],
	other => [
	    {
		name => 'display',
		type => 'Name',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'Ride.user_id',
		in_select => 0,
	    },
	],
	group_by => ['Ride.ride_date'],
    });
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows() : array_ref

=cut

sub internal_load_rows {
    return [
	{
	    'Ride.ride_date' => undef,
	    display => 'Select a date',
	},
	@{shift->SUPER::internal_load_rows(@_)},
    ];
}

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row()

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{display} ||= Bivio::Type::Date->to_string($row->{'Ride.ride_date'})
	. '  '
	. Bivio::Type::Date->english_day_of_week($row->{'Ride.ride_date'});
    return 1;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
