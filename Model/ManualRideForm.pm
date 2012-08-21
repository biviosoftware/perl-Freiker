# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');
my($_RT) = b_use('Type.RideType');

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($frl) = $req->get('Model.FreikerRideList');
    my($d) = $self->get('Ride.ride_date');
    my($freiker_id) = $frl->get_user_id;
    $req->with_user($freiker_id, sub {
	my($cid) = $self->new_other('RealmUser')
	    ->club_id_for_freiker($freiker_id);
        $req->with_realm($req->get('auth_user_id'), sub {
	    $self->new_other('Lock')->acquire_unless_exists;
	    return $self->internal_put_error('Ride.ride_date' => 'DATE_RANGE')
		if $_D->compare_defined($d, $_D->local_today) > 0;
	    return $self->internal_put_error('Ride.ride_date' => 'EXISTS')
		if $frl->find_row_by_date($d);
	    $self->new_other('Ride')->create({
		user_id => $freiker_id,
		club_id => $cid,
		ride_date => $d,
		ride_type => $_RT->row_tag_get($freiker_id, $req),
	    });
	});
	return;
    });
    return
	if $self->in_error;
    return {
	carry_query => 1,
    };
}

sub execute_cancel {
    return {
	carry_query => 1,
    };
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

sub internal_pre_execute {
    my($self) = @_;
    # SECURITY: Ensure user can access this Freiker
    $self->req('Model.FreikerRideList')->get_query->get('parent_id'),
    return shift->SUPER::internal_pre_execute(@_);
}

1;
