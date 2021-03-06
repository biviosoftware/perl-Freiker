# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmPrizeList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_P);

sub image_path {
    return ($_P ||= b_use('Model.Prize')->get_instance)->image_path(shift, 'Prize.');
}

sub image_uri {
    my(undef, $delegator) = shift->delegated_args(@_);
    return $delegator->req->format_uri({
	realm => $delegator->get('RealmOwner.name'),
	task_id => 'MERCHANT_FILE',
	path_info => $delegator->image_path,
	query => undef,
	no_context => 1,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => ['Prize.prize_id'],
        order_by => [
	    'Prize.ride_count',
	    'Prize.name',
	    'RealmOwner.display_name',
	],
	other => [
	    'RealmOwner.name',
	    'Prize.description',
	    'Prize.detail_uri',
	    'Prize.prize_status',
	    'Prize.retail_price',
	    'Website.url',
	    ['Prize.realm_id', 'RealmOwner.realm_id', 'Website.realm_id'],
	    ['Website.location', [b_use('Model.Website')->DEFAULT_LOCATION]],
	],
    });
}

1;
