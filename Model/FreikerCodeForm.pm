# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub execute_ok {
    my($self) = @_;
    return unless my $new_uid = _validate_user($self, _validate_club($self));
    return unless _validate_rides($self, $new_uid);
    return _update_user($self, $new_uid);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'FreikerCode.freiker_code',
	    'Club.club_id',
	],
	other => [
	    'FreikerCode.user_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('ClubSelectList')->load_all;
    return;
}

sub _iterate_rides {
    my($self, $user_id, $op) = @_;
    $self->new_other('Ride')->do_iterate(
	$op,
        'unauth_iterate_start',
        'ride_date',
	{
	    user_id => $user_id,
	},
    );
    return;
}

sub _update_user {
    my($self, $new_uid) = @_;
    my($curr_uid) = $self->get('FreikerCode.user_id');
    return if $curr_uid eq $new_uid;
    _iterate_rides($self, $new_uid, sub {
	my($it) = @_;
	my($v) = $it->get_shallow_copy;
	$it->unauth_delete;
	$v->{user_id} = $curr_uid;
	$it->create($v);
	return 1;
    });
    $self->get_model('FreikerCode')->update({
	user_id => $curr_uid,
    });
    $self->req->with_realm(
	$self->get('Club.club_id'),
	sub {
	    $self->new_other('RealmUser')
		->create_freiker_unless_exists($curr_uid);
	    return;
	},
    );
    $self->new_other('User')->unauth_delete_realm($new_uid);
    return;
}

sub _validate_club {
    my($self) = @_;
    my($l) = $self->req('Model.ClubSelectList');
    return $self->internal_put_error('Club.club_id' => 'NULL')
	if $l->EMPTY_KEY_VALUE eq $self->get('Club.club_id');
    return $self->internal_put_error('Club.club_id' => 'NOT_FOUND')
	unless $l->find_row_by_id($self->get('Club.club_id'));
    $self->internal_put_field(
	'FreikerCode.club_id' => $self->get('Club.club_id'));
    return $self->internal_put_error('FreikerCode.freiker_code' => 'NOT_FOUND')
	unless my $fcl = $self->new_other('FreikerCodeList')->unauth_load_all({
	    auth_id => $self->get('FreikerCode.club_id'),
	})->find_row_by_code($self->get('FreikerCode.freiker_code'));
    return $fcl->get('FreikerCode.user_id');
}

sub _validate_rides {
    my($self, $new_uid) = @_;
    return 1
	unless my $frl = $self->req->unsafe_get('Model.FreikerRideList');
    my($new_dates) = {};
    _iterate_rides(
	$self, $new_uid, sub {
	    $new_dates->{shift->get('ride_date')} = 1;
	    return 1;
	},
    );
    my($overlap) = {};
    my($curr_uid);
    $frl->do_rows(sub {
	my($it) = @_;
	$curr_uid ||= $it->get('Ride.user_id');
	my($d) = $it->get('Ride.ride_date');
#TODO: Delete manual override
	$overlap->{$d}++
	    if $new_dates->{$d};
	return 1;
    });
    return $self->internal_put_error_and_detail(
	'FreikerCode.freiker_code' => 'MUTUALLY_EXCLUSIVE',
	keys(%$overlap) > 10 ? keys(%$overlap) . ' days'
	    : join(', ', sort(map($_D->to_string($_), keys(%$overlap)))),
    ) if keys(%$overlap);
    $self->internal_put_field('FreikerCode.user_id' => $curr_uid)
	if $curr_uid;
    return 1;
}

sub _validate_user {
    my($self, $new_uid) = @_;
    return
	unless $new_uid;
    return $self->internal_put_error('FreikerCode.freiker_code' => 'EXISTS')
	if $self->new_other('RealmUser')->is_registered_freiker($new_uid);
    $self->internal_put_field('FreikerCode.user_id' => $new_uid);
    return $new_uid;
}

1;
