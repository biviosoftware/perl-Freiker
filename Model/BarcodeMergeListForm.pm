# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeMergeListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty_row {
    shift->internal_put_field(want_merge => 1);
    return;
}

sub execute_ok_row {
    my($self) = @_;
    next unless $self->get('want_merge');
    my($lm) = $self->get_list_model;
    my($to, $from) = map(
	$self->new_other('RealmOwner')->unauth_load_or_die({
	    name => $_,
	}),
	$lm->get(qw(RealmOwner.name RealmOwner_2.name)));
    $self->new_other('RealmUser')->do_iterate(
	sub {
	    shift->unauth_delete;
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
	{user_id => $from->get('realm_id')},
    );
    $self->get_request->set_realm($from);
#TODO: Check first
    $self->new_other('Ride')->do_iterate(
	sub {
	    my($r) = @_;
	    $r->create({
		%{$r->get_shallow_copy},
		user_id => $to->get('realm_id'),
	    });
	    $r->delete;
	    return 1;
	},
	'ride_date',
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
		name => 'want_merge',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

1;
