# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmPrizeList;
use strict;
use Bivio::Base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_P) = Bivio::Biz::Model->get_instance('Prize');

sub image_file_name {
    my($self) = @_;
    return $_P->image_file_name($self, 'Prize.');
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
	    'RealmOwner.name',
	    'RealmOwner.display_name',
	],
	other => [
	    'Prize.description',
	    'Prize.detail_uri',
	    'Website.url',
	    ['Prize.realm_id', 'RealmOwner.realm_id', 'Website.realm_id'],
	    ['Website.location', [$self->get_instance('Website')->DEFAULT_LOCATION]],
	],
    });
}

1;
