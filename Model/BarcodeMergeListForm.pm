# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeMergeListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    my($to, $from) = map(
	$self->new_other('RealmOwner')->unauth_load_or_die({
	    name => $_,
	}),
	$lm->get(
	    $self->get('reverse_merge') ? qw(RealmOwner.name RealmOwner_2.name)
	    : qw(RealmOwner_2.name RealmOwner.name),
	));
    my($req) = $self->get_request;
    my($prev) = $req->get('auth_realm');
    $self->new_other('Ride')->do_iterate(
	sub {
	    my($r) = @_;
	    my($v) = {
		%{$r->get_shallow_copy},
		user_id => $to->get('realm_id'),
	    };
	    $r->unauth_delete;
	    if ($r->unauth_load($v)) {
		$self->internal_put_error(reverse_merge => 'MERGE_OVERLAP');
		$self->internal_put_field('Ride.ride_date' => $v->{ride_date});
		return 0;
	    }
	    $r->create($v);
	    return 1;
	},
	'unauth_iterate_start',
	'ride_date',
	{user_id => $from->get('realm_id')},
    );
    return
	if $self->in_error;
    $self->new_other('RealmUser')->do_iterate(
	sub {
	    shift->delete;
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
	{user_id => $from->get('realm_id')},
    );
    $self->new_other('User')->unauth_load_or_die({
	user_id => $from->get('realm_id'),
    })->cascade_delete;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'BarcodeMergeList',
	visible => [
	    {
		name => 'reverse_merge',
		type => 'Boolean',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
	other => [
	    {
		name => 'Ride.ride_date',
		in_list => 1,
	    },
	],
    });
}

1;
