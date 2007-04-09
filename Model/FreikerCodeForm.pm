# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    _iterate_rides($self, sub {
	shift->update({realm_id => $self->get('Ride.realm_id')});
	return 1;
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'FreikerCode.freiker_code',
	],
	other => [
	    'Ride.realm_id',
	    'FreikerCode.club_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    if (my $frl = $self->get_request->unsafe_get('Model.FreikerRideList')) {
	$self->internal_put_field('FreikerCode.club_id' => $frl->get_club_id);
	$self->internal_put_field('Ride.realm_id' => $frl->get('Ride.realm_id'));
    }
    return;
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    my($req) = $self->get_request;
    return $self->internal_put_error('FreikerCode.freiker_code' => 'NOT_FOUND')
	unless $self->new_other('FreikerCodeList')->unauth_load_all({
	    auth_id => $self->get('FreikerCode.club_id'),
	})->find_row_by_code($self->get('FreikerCode.freiker_code'));
    my($dates) = {};
    $self->internal_put_error('FreikerCode.freiker_code' => 'EXISTS');
    _iterate_rides(
	$self, sub {
	    $self->internal_clear_error('FreikerCode.freiker_code')
		unless %$dates;
	    $dates->{shift->get('ride_date')} = 1;
	    return 1;
	},
    );
    return if $self->in_error;
    return unless my $frl = $req->get('Model.FreikerRideList');
    $frl->do_rows(sub {
        $self->internal_put_error(
	    'FreikerCode.freiker_code' => 'MUTUALLY_EXCLUSIVE'
	) if $dates->{shift->get('Ride.ride_date')};
	return 1;
    });
    return;
}

sub _iterate_rides {
    my($self, $op) = @_;
    $self->new_other('Ride')->do_iterate(
	$op,
	'ride_date',
	{
	    freiker_code => $self->get('FreikerCode.freiker_code'),
	    realm_id => $self->get('FreikerCode.club_id'),
	},
    );
    return;
}

1;
