# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmRideList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FLQF) = b_use('Model.FreikerListQueryForm');

sub LOAD_ALL_SIZE {
    return 10_000_000;
}

sub AUTH_ID {
    return undef;
}

sub OTHER_COLUMNS {
    return (
	[qw(Ride.club_id RealmOwner.realm_id)],
	'RealmOwner.realm_id',
	'RealmOwner.display_name',
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [qw(Ride.user_id Ride.ride_date)],
	other => [
	    $self->OTHER_COLUMNS,
	    [qw(Ride.user_id FreikerInfo.user_id)],
	    'FreikerInfo.distance_kilometers',
	],
	other_query_keys => [qw(fr_begin fr_end)],
	auth_id => $self->AUTH_ID,
    });
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
