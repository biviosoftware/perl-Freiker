# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
#TODO: 2006
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	order_by => [qw(
	    RealmOwner.name
	    RealmOwner.display_name
	)],
	other => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
            [qw(RealmUser_2.realm_id)],
	],
	auth_id => ['RealmUser.realm_id'],
	primary_key => ['RealmOwner.name'],
	from => 'FROM realm_owner_t, realm_user_t'
	    . ' LEFT JOIN realm_user_t realm_user_t_2'
	    . ' ON (realm_user_t.user_id = realm_user_t_2.user_id'
	    . ' AND realm_user_t_2.role = '
	    . Bivio::Auth::Role->STUDENT->as_sql_param
	    . ')',
	where => [
	    'realm_user_t.role = ', Bivio::Auth::Role->FREIKER->as_sql_param,
        ],
    });
}

1;
