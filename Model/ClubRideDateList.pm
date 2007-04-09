# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRideDateList;
use strict;
use base 'Freiker::Model::YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['Ride.ride_date'],
        order_by => ['Ride.ride_date'],
        group_by => ['Ride.ride_date'],
	parent_id => [qw(RealmUser.realm_id)],
	other => [
	    map(+{
		name => $_,
		in_select => 0,
	    }, qw(RealmUser.role RealmUser.user_id Ride.freiker_code)),
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where([qw(Ride.realm_id RealmUser.user_id)]);
    return;
}

sub is_date_ok {
    my($self, $date) = @_;
    $self->load_all({
	parent_id => $self->get_request->map_user_realms(
	    sub {shift->{'RealmUser.realm_id'}},
	    {'RealmOwner.realm_type' => Bivio::Auth::RealmType->CLUB},
	)->[0],
    }) unless $self->is_loaded;
    return $self->find_row_by_date($date) ? 1 : 0;
}

1;
