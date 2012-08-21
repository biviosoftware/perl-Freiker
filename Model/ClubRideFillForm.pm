# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRideFillForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_RT) = b_use('Type.RideType');

sub execute_ok {
    my($self) = @_;
    my($add) = $self->get('Ride.ride_date');
    my($before) = 0;
    my($end) = [];
    $self->new_other('ClubRideDateList')->do_iterate(sub {
        my($d) = shift->get('Ride.ride_date');
	my($delta) = $_D->delta_days($add, $d);
	if ($delta == 0) {
	    $self->internal_put_error('Ride.ride_date', 'EXISTS');
	    return 0;
	}
	return 0
	    if $delta < 0 && ++$before >= 2;
	unshift(@$end, $d);
	return 1;
    });
    return
	if $self->in_error;
    return $self->internal_put_error('Ride.ride_date', 'NOT_NEGATIVE')
	if $before < 1;
    foreach my $u (@{
	$self->new_other('FreikerNearDateList')->map_iterate(
	    sub {shift->get('Ride.user_id')},
	    {
		begin_date => $end->[0],
		end_date => $end->[$#$end],
	    },
	)
    }) {
	$self->new_other('Ride')->create({
	    user_id => $u,
	    ride_date => $add,
	    club_id => $self->req('auth_id'),
	    ride_type => $_RT->row_tag_get($u, $self->req),
	});
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Ride.ride_date',
	],
    });
}

1;
