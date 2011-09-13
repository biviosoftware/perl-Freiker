# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmRideList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_K) = b_use('Type.Kilometers');
my($_FLQF) = b_use('Model.FreikerListQueryForm');
my($_D) = b_use('Type.Date');
my($_FL) = b_use('Model.FreikerList');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [[qw(Ride.user_id FreikerInfo.user_id)]],
	other => [
	    qw(
		Ride.ride_date
		FreikerInfo.distance_kilometers
	    ),
	    $self->field_decl([
		[qw(ride_count Integer)],
		[qw(current_miles Miles)],
		[qw(current_kilometers Kilometers)],
		[qw(calories Integer)],
		[qw(co2_saved Integer)],
	    ]),
	],
	other_query_keys => [qw(fr_begin fr_end)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{ride_count} = 1;
    $row->{current_kilometers} = $row->{'FreikerInfo.distance_kilometers'}
	&& 2 * $row->{'FreikerInfo.distance_kilometers'};
    $row->{current_miles} = $row->{'FreikerInfo.distance_kilometers'}
	&& $_K->to_miles($row->{current_kilometers});
    $row->{calories} = $row->{current_miles}
	&& $row->{current_miles} * $_FL->CALORIES_PER_MILE;
    $row->{co2_saved} = $row->{current_miles}
	&& $row->{current_miles} * $_FL->CO2_POUNDS_PER_MILE;
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->GTE('Ride.ride_date', [$_FLQF->get_value_fr($self, 'fr_begin')]),
    ) if $_FLQF->get_value_fr($self, 'fr_begin');
    $stmt->where(
	$stmt->LTE('Ride.ride_date', [$_FLQF->get_value_fr($self, 'fr_end')]),
    ) if $_FLQF->get_value_fr($self, 'fr_end');
    return;
}

1;
