# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_OVERLAP_SLOP) = 1;
my($_FREIKER) = __PACKAGE__->use('Auth.Role')->FREIKER;

sub execute_empty {
    my($self) = @_;
    return 
	unless my $frl = $self->req->unsafe_get('Model.FreikerRideList');
    $self->internal_put_field(
	'Club.club_id' => $self->new_other('RealmUser')
	    ->club_id_for_freiker($frl->get_query->get('parent_id')));
    return;
}

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
	hidden => [
	    {
		name => 'super_user_override',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
	other => [
	    'FreikerCode.user_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('ClubList')->load_all;
    return;
}

sub _delete_rides {
    my($self, $rides) = @_;
    return unless @$rides;
    $self->map_by_two(
	sub {
	    my($date, $user_id) = @_;
	    $self->new_other('Ride')->unauth_delete({
		ride_date => $date,
		user_id => $user_id,
	    });
	},
	$rides,
    );
    return;
}

sub _iterate_rides {
    my($self, $user_id, $op) = @_;
    $self->new_other('Ride')->do_iterate(
	$op,
        'unauth_iterate_start',
        'ride_date',
	{user_id => $user_id},
    );
    return;
}

sub _super_user_override {
    my($self) = @_;
    return 0
	unless $self->req->is_substitute_user;
    return 1
	if $self->unsafe_get('super_user_override');
    $self->internal_put_field(super_user_override => 1);
    return 0;
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
    $self->new_other('FreikerCode')->do_iterate(
	sub {
	    shift->update({user_id => $curr_uid});
	    return 1;
	},
	'unauth_iterate_start',
	'freiker_code',
	{user_id => $new_uid},
    );
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
    my($l) = $self->req('Model.ClubList');
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
    my($new_auto) = {};
    my($new_manual) = {};
    _iterate_rides(
	$self, $new_uid, sub {
	    my($d, $up) = shift->get(qw(ride_date ride_upload_id));
	    ($up ? $new_auto : $new_manual)->{$d} = 1;
	    return 1;
	},
    );
    my($can_delete) = {};
    my($overlap) = {};
    my($curr_uid) = $frl->get_query->get('parent_id');
    $frl->do_rows(sub {
	my($it) = @_;
	my($d, $up) = $it->get(qw(Ride.ride_date Ride.ride_upload_id));
	if ($new_manual->{$d} || $new_auto->{$d}) {
	    if ($new_auto->{$d} && $up) {
		$overlap->{$d} = $new_uid;
	    }
	    else {
		$can_delete->{$d} = $up ? $curr_uid : $new_uid;
	    }
	}
	return 1;
    });
    return $self->internal_put_error_and_detail(
	'FreikerCode.freiker_code' => 'MUTUALLY_EXCLUSIVE',
	keys(%$overlap) > 10 ? keys(%$overlap) . ' days'
	    : join(', ', sort(map($_D->to_string($_), keys(%$overlap)))),
    ) if keys(%$overlap) > $_OVERLAP_SLOP && !_super_user_override($self);
    $self->internal_put_field('FreikerCode.user_id' => $curr_uid);
    _delete_rides($self, [%$can_delete, %$overlap]);
    return 1;
}

sub _validate_user {
    my($self, $new_uid) = @_;
    return
	unless $new_uid;
    if (my $fid = $self->new_other('RealmUser')
	    ->unsafe_family_id_for_freiker($new_uid)
    ) {
	$self->internal_put_error('FreikerCode.freiker_code' => 'EXISTS');
	return unless _super_user_override($self);
	$self->internal_clear_error('FreikerCode.freiker_code');
	$self->new_other('RealmUser')->unauth_delete({
	    user_id => $new_uid,
	    realm_id => $fid,
	    role => $_FREIKER,
	});
    }
    $self->internal_put_field('FreikerCode.user_id' => $new_uid);
    return $new_uid;
}

1;
