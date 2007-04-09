# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($frl) = $req->get('Model.FreikerRideList');
    my($d) = $self->get('Ride.ride_date');
    $req->with_user($frl->set_cursor_or_die(0)->get('Ride.realm_id'), sub {
	return $self->internal_put_error('Ride.ride_date' => 'NOT_FOUND')
	    unless $self->new_other('ClubRideDateList')->is_date_ok($d);
        $req->with_realm($req->get('auth_user_id'), sub {
	    $self->new_other('Lock')->acquire_unless_exists;
	    return $self->internal_put_error('Ride.ride_date' => 'EXISTS')
		if $frl->find_row_by_date($d);
	    $self->new_other('Ride')->create({
		realm_id => $req->get('auth_id'),
		ride_date => $d,
		freiker_code => $frl->set_cursor_or_die(0)
		    ->get('Ride.freiker_code'),
	    });
	});
	return;
    });
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
