# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ManualRideListForm;
use strict;
use Bivio::Base 'Biz.ExpandableListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_RU) = b_use('Model.RealmUser');
my($_FREIKER) = b_use('Auth.Role')->FREIKER;

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(Ride.ride_date Ride.ride_type)];
}

sub ROW_INCREMENT {
    return 10;
}

sub execute_cancel {
    return {
	carry_query => 1,
    },
}

sub execute_empty_row {
    my($self) = @_;
    shift->SUPER::execute_empty_row(@_);
    return
	unless $self->unsafe_get('last_ride');
    $self->internal_put_field(
	'Ride.ride_type' => $self->get('last_ride')->get('ride_type'),
    );
    return;
}

sub execute_ok_end {
    return {
	carry_query => 1,
    } unless shift->in_error;
    return;
}

sub execute_ok_row {
    my($self) = @_;
    my($d) = $self->get('Ride.ride_date');
    return $self->internal_clear_error('Ride.ride_date')
	unless $d;
    return $self->internal_put_error('Ride.ride_date' => 'DATE_RANGE')
	if $_D->compare_defined($d, $_D->local_today) > 0;
    return $self->internal_put_error('Ride.ride_date' => 'SYNTAX_ERROR')
	if $_D->is_weekend($d);
    my($uid) = $self->get('RealmUser.user_id');
    my($r) = $self->new_other('Ride');
    $r->unauth_load({
	user_id => $uid,
	ride_date => $d,
    });
    return $self->internal_put_error('Ride.ride_date' => 'EXISTS')
	if $r->is_loaded;
    $self->internal_put_field('Ride.ride_type' =>
				  $self->get('Ride.ride_type_0'))
	if $self->unsafe_get('use_type_for_all_0');
    $r->create({
	user_id => $uid,
	club_id => $_RU->club_id_for_freiker($uid),
	ride_date => $d,
	ride_type => $self->get('Ride.ride_type'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	list_class => 'ManualRideList',
	visible => [
	    {
		name => 'Ride.ride_date',
		constraint => 'NOT_NULL',
		in_list => 1,
	    }, {
		name => 'Ride.ride_type',
		constraint => 'NOT_ZERO_ENUM',
		in_list => 1,
	    }, {
		name => 'use_type_for_all',
		type => 'Boolean',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
	other => [
	    'RealmUser.user_id',
	    'RealmOwner.display_name',
	    $self->field_decl([[qw(last_ride Freiker::Model::Ride NONE)]]),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    # SECURITY: Ensure user can access this Freiker
    my($uid) = $self->req('Model.ManualRideList')->get_query->get('parent_id');
    $self->internal_put_field('RealmUser.user_id' => $uid);
    $self->internal_put_field('RealmOwner.display_name'	=>
	join(' ',
	    $self->new_other('RealmOwner')
		->unauth_load_or_die({realm_id => $uid})
		->get('display_name'),
	     $self->new_other('UserFreikerCodeList')
		 ->get_display_name($uid),
	 ),
    );
    $self->internal_put_field(last_ride => undef);
    $self->new_other('Ride')->do_iterate(sub {
	$self->internal_put_field(last_ride => shift);
	return 0;
    }, 'unauth_iterate_start', 'ride_date desc', {
	user_id => $uid,
    });
    return @res;
}

sub validate_row {
    my($self) = @_;
    my($no_date) = $self->unsafe_get('Ride.ride_date') ? 0 : 1;
    $self->internal_clear_error('Ride.ride_date')
	if $no_date;
    $self->internal_clear_error('Ride.ride_type')
	if $self->get('use_type_for_all_0') || $no_date;
    return;
}

1;
