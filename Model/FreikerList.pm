# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use Bivio::Base 'Model.FreikerBaseList';
use Freiker::Biz;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PRIZE_SELECT_LIST {
    return 'PrizeSelectList';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        order_by => [
	    'RealmOwner.display_name',
	    {
		name => 'prize_debit',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => '(SELECT SUM(ride_count) FROM prize_coupon_t WHERE prize_coupon_t.user_id = realm_user_t.user_id) AS prize_debit',
		sort_order => 0,
	    },
	],
	other => [
	    {
		name => 'prize_credit',
		type => 'Integer',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'can_select_prize',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'prize_select_list',
		type => 'Model.PrizeSelectList',
		constraint => 'NOT_NULL',
	    },
	],
	auth_id => 'RealmUser.realm_id',
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{prize_credit} = $row->{ride_count} - ($row->{prize_debit} ||= 0);
    $row->{can_select_prize}
	= ($row->{prize_select_list}
	    = $self->new_other($self->PRIZE_SELECT_LIST)
		->load_for_user_and_credit(
		    $row->{'RealmUser.user_id'}, $row->{prize_credit})
	)->get_result_set_size ? 1 : 0;
    return 1;
}

1;
