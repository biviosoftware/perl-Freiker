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

sub execute_empty_row {
    my($self) = @_;
    return
	unless $self->unsafe_get('last_ride');
    $self->internal_put_field(
	'Ride.ride_type' => $self->get('last_ride')->get('ride_type'),
    );
    return;
}

sub execute_ok_row {
    my($self) = @_;
    my($d) = $self->get('Ride.ride_date');
    return
	unless $d;
    my($uid) = $self->get('RealmUser.user_id');
    my($r) = $self->new_other('Ride');
    $r->unauth_load({
	user_id => $uid,
	ride_date => $d,
    });
    return $self->internal_put_error('Ride.ride_date', 'EXISTS')
	if $r->is_loaded;
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
    my($uid) = $self->req('query')
	->{b_use('SQL.ListQuery')->to_char('parent_id')};
    my($ru) = $self->new_other('RealmUser');
    $ru->unsafe_load({
	user_id => $uid,
	role => $_FREIKER,
    });
    b_die($uid, ': user is not a FREIKER in this realm')
	unless $ru->is_loaded;
    $self->internal_put_field('RealmUser.user_id' => $uid);
    $self->internal_put_field('RealmOwner.display_name'
	=> $self->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $uid})->get('display_name'));
    $self->internal_put_field(last_ride => undef);
    $self->new_other('Ride')->do_iterate(sub {
	$self->internal_put_field(last_ride => shift);
	return 0;
    }, 'unauth_iterate_start', 'ride_date desc', {
	user_id => $uid,
    });
    return @res;
}

1;
