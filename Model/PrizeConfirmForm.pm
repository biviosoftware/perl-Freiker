# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeConfirmForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_pre_execute {
    my($self) = @_;
    $self->clear_errors;
    $self->new_other('PrizeSelectList')->execute_load_this($self->req);
    my($prize) = $self->get_request()->get('Model.PrizeSelectList');
    unless ($prize->get_result_set_size) {
	$self->internal_put_error('Prize.name' => 'PRIZE_NOT_EARNED');
    }
    else {
	$self->internal_put_field('Prize.name' => $prize->get('Prize.name'));
	$self->internal_put_field('PrizeRideCount.ride_count'
            => $prize->get('PrizeRideCount.ride_count'));
    }
}

sub execute_ok {
    my($self) = @_;
    my($prize) = $self->get_request()->get('Model.PrizeSelectList');
    my($pc) = $self->new_other('PrizeCoupon')->create({
        realm_id => $self->new_other('RealmOwner')->unauth_load_or_die({
            name => Bivio::IO::ClassLoader->simple_require('Freiker::Test')
	        ->DISTRIBUTOR_NAME,
        })->get('realm_id'),
        user_id => $prize->get('RealmUser.user_id'),
        prize_id => $prize->get('Prize.prize_id'),
        ride_count => $prize->get('PrizeRideCount.ride_count'),
    });
    return {
        task_id => 'next',
        method => 'client_redirect',
	query => {
	    parent_id => $prize->get('RealmUser.user_id'),
	    this => $pc->get('coupon_code'),
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [qw(
	    Prize.name
	    PrizeRideCount.ride_count
	)],
    });
}

sub is_field_editable {
    return 0;
}

1;
