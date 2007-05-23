# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeSelectList;
use strict;
use Bivio::Base 'Model.ClubPrizeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_query_for_this {
    my($self) = @_;
    return {
        Bivio::SQL::ListQuery->to_char('parent_id')
	    => $self->get('RealmUser.user_id'),
        Bivio::SQL::ListQuery->to_char('this') => $self->get('Prize.prize_id'),
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	parent_id => ['RealmUser.user_id'],
	other => [
	    [qw(Prize.prize_id PrizeRideCount.prize_id)],
	    [qw(PrizeRideCount.realm_id RealmUser.realm_id)],
	    ['RealmUser.role', ['MEMBER']],
	],
	order_by => [qw(
	    PrizeRideCount.ride_count
	)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;

    my($available_rides) = 0;
    $self->get_request->with_realm($row->{'RealmUser.user_id'}, sub {
	$self->new_other('Ride')->do_iterate(sub {
	    $available_rides++;
	    return 1;
	}, 'freiker_code');
    });
    $self->new_other('PrizeCoupon')->do_iterate(sub {
        $available_rides -= shift->get('ride_count');
	return 1;
    }, 'unauth_iterate_start', 'prize_id', {
        user_id => $row->{'RealmUser.user_id'},
    });

    return 0
	if $row->{'PrizeRideCount.ride_count'} > $available_rides;
    return 1;
}

1;
