# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeForm;
use strict;
use Bivio::Base 'Model.FreikerForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_OVERLAP_SLOP) = 1;
my($_FREIKER) = b_use('Auth.Role')->FREIKER;
my($_F) = b_use('ShellUtil.Freiker');
my($_K) = b_use('Type.Kilometers');

sub execute_empty {
    my($self) = @_;
    if (my $uid = $self->unsafe_get('FreikerCode.user_id')) {
	$self->internal_put_field(
	    'Club.club_id' => $self->new_other('RealmUser')
		->club_id_for_freiker($uid),
	) if $self->get('allow_club_id');
    }
    my($res) = shift->SUPER::execute_empty(@_);
    if ($self->get('in_parent_realm')) {
	$self->internal_put_field('User.last_name' =>
	    $self->new_other('User')->load->unsafe_get('last_name'));
	_put_address($self, $self->new_other('Address')->load);
	$self->new_other('RealmUser')->do_iterate(sub {
            my($ru) = @_;
	    my($uid) = $ru->get('user_id');
	    return 1
		if $uid eq $ru->get('realm_id');
	    my($fi) = $self->new_other('FreikerInfo');
	    $fi->unauth_load({user_id => $uid});
	    return 1
		unless $fi->is_loaded
		    && (my $k = $fi->unsafe_get('distance_kilometers'));
	    my($ka) = $self->new_other('Address');
	    $ka->unauth_load({realm_id => $uid});
	    return 1
		unless $ka->is_loaded;
	    $self->internal_put_field(
		miles => $_K->to_miles($k),
		kilometers => $k,
		'Club.club_id' => $ru->club_id_for_freiker($uid),
	    );
	    _put_address($self, $ka);
	    return 0;
	});
    }
    return $res;
}

sub execute_ok {
    my($self) = @_;
    return
	unless my $uid = _validate_club($self);
    return
	unless _validate_user($self, $uid);
    return
	unless _validate_rides($self, $uid);
    _update_user($self, $uid);
    return shift->SUPER::execute_ok(@_) || {
    	query => {
	    'ListQuery.parent_id' => $self->get('FreikerCode.user_id'),
	},
    };

}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'FreikerCode.freiker_code',
	    {
		name => 'no_freiker_code',
		type => 'Boolean',
		constraint => 'NONE',
	    },
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
	    $self->field_decl(
		[qw(allow_club_id in_parent_realm)],
		'Boolean',
	    ),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->new_other('ClubList')->load_all;
    $self->internal_put_field('Club.club_id' => $self->req('auth_id'))
	unless $self->get('allow_club_id');
    return @res;
}

sub validate {
    my($self) = @_;
    $self->internal_clear_error('FreikerCode.freiker_code')
	if $self->unsafe_get('no_freiker_code');
    $self->internal_clear_error('Club.club_id')
	unless $self->get('allow_club_id');
    return shift->SUPER::validate(@_);
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

sub _put_address {
    my($self, $model) = @_;
    map({
	$self->internal_put_field(
	    "Address.$_" => $model->unsafe_get($_),
	);
    } qw(street1 street2 city state zip country)),
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
    my($self, $code_uid) = @_;
    my($curr_uid) = $self->get('FreikerCode.user_id');
    my($ru) = $self->new_other('RealmUser')
	->create_freiker_unless_exists($curr_uid, $self->get('Club.club_id'));
    $ru->create_freiker_unless_exists($curr_uid, $self->req('auth_id'))
	if $self->get('in_parent_realm');
    return
	if $curr_uid eq $code_uid;
    _iterate_rides($self, $code_uid, sub {
	my($it) = @_;
	my($v) = $it->get_shallow_copy;
	$it->unauth_delete;
	$v->{user_id} = $curr_uid;
	$it->create($v);
	return 1;
    });
    foreach my $x (
	[qw(FreikerCode freiker_code)],
	[qw(GreenGear green_gear_id)],
	[qw(PrizeCoupon prize_id)],
	[qw(PrizeReceipt receipt_code)],
    ) {
	my($model, $order_by, $field) = @$x;
	$field ||= 'user_id';
	$self->new_other($model)->do_iterate(
	    sub {
		shift->update({$field => $curr_uid});
 		return 1;
	    },
	    'unauth_iterate_start',
	    $order_by,
	    {$field => $code_uid},
	);
    }
    $self->new_other('User')->unauth_delete_realm($code_uid);
#TODO: Implicit coupling.  This will copy existing FreikerInfo, which hasn't
#      been updated yet, because FreikerForm has not yet updated it yet, which
#      likely includes a distance calculation
    $self->req->with_user($curr_uid, sub {$_F->audit_clubs});
    return;
}

sub _validate_club {
    my($self) = @_;
    if ($self->get('allow_club_id')) {
	my($l) = $self->req('Model.ClubList');
	return $self->internal_put_error('Club.club_id' => 'NULL')
	    if $l->EMPTY_KEY_VALUE eq $self->get('Club.club_id');
	return $self->internal_put_error('Club.club_id' => 'NOT_FOUND')
	    unless $l->find_row_by_id($self->get('Club.club_id'));
    }
    $self->internal_put_field(
	'FreikerCode.club_id' => $self->get('Club.club_id'));
    if ($self->unsafe_get('no_freiker_code')) {
	return $self->internal_put_error(
	    'FreikerCode.freiker_code' => 'SYNTAX_ERROR')
	    if $self->get('FreikerCode.freiker_code');
	my($uid) = $self->new_other('User')->create_freiker({
	    %{$self->get_model_properties('User')},
	});
	$self->internal_put_field('FreikerCode.user_id' => $uid);
	return $uid;
    } else {
	return $self->internal_put_error(
	    'FreikerCode.freiker_code' => 'NOT_FOUND')
	    unless my $fcl = $self->new_other('FreikerCodeList')
		->unauth_load_all({
		    auth_id => $self->get('FreikerCode.club_id'),
		})->find_row_by_code($self->get('FreikerCode.freiker_code'));
	return $fcl->get('FreikerCode.user_id');
    }
}

sub _validate_rides {
    my($self, $code_uid) = @_;
    return 1
	unless my $frl = $self->ureq('Model.FreikerRideList');
    my($new_auto) = {};
    my($new_manual) = {};
    _iterate_rides(
	$self, $code_uid, sub {
	    my($d, $up) = shift->get(qw(ride_date ride_upload_id));
	    ($up ? $new_auto : $new_manual)->{$d} = 1;
	    return 1;
	},
    );
    my($can_delete) = {};
    my($overlap) = {};
    my($curr_uid) = $self->get('FreikerCode.user_id');
    $frl->do_rows(sub {
	my($it) = @_;
	my($d, $up) = $it->get(qw(Ride.ride_date Ride.ride_upload_id));
	if ($new_manual->{$d} || $new_auto->{$d}) {
	    if ($new_auto->{$d} && $up) {
		$overlap->{$d} = $code_uid;
	    }
	    else {
		$can_delete->{$d} = $up ? $curr_uid : $code_uid;
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
    my($self, $code_uid) = @_;
    my($fid) = $self->new_other('RealmUser')
	->unsafe_family_id_for_freiker($code_uid);
    if (! $self->unsafe_get('no_freiker_code') && $fid) {
	$self->internal_put_error('FreikerCode.freiker_code' => 'EXISTS');
	return 0
	    unless _super_user_override($self);
	$self->internal_clear_error('FreikerCode.freiker_code');
	$self->new_other('RealmUser')->unauth_delete({
	    user_id => $code_uid,
	    realm_id => $fid,
	    role => $_FREIKER,
	});
    }
    $self->internal_put_field('FreikerCode.user_id' => $code_uid)
	unless $self->unsafe_get('FreikerCode.user_id');
    return 1;
}

1;
