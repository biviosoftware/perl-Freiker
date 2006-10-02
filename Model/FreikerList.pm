# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use base 'Bivio::Biz::ListModel';
use Freiker::Biz;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [
	    ['RealmUser.user_id', 'Ride.realm_id', 'RealmOwner.realm_id'],
	],
        order_by => [
	    'RealmOwner.display_name',
	],
	other => [
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => 'COUNT(*) as ride_count',
		sort_order => 0,
	    },
	    ['RealmUser.role', [Bivio::Auth::Role->MEMBER]],
	    {
		name => 'Ride.freiker_code',
		in_select => 0,
	    },
	    {
		name => 'Ride.ride_date',
		in_select => 0,
	    },
	    {
		name => 'RealmUser.role',
		in_select => 0,
	    },
	],
	auth_id => 'RealmUser.realm_id',
	group_by => [qw(
            RealmUser.user_id
            RealmOwner.display_name
	)],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(
	$stmt->GTE(
	    'Ride.ride_date', [Freiker::Biz->current_school_year_start_date]),
	$stmt->LTE(
	    'Ride.ride_date', [Freiker::Biz->current_school_year_end_date]),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
