# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use Bivio::Base 'Model.YearBaseList';
use Freiker::Biz;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
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
		select_value => '(SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id)',
		sort_order => 0,
	    },
	    ['RealmUser.role', ['FREIKER']],
	],
	auth_id => 'RealmUser.realm_id',
    });
}

1;
