# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmFreikometerList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_FOLDER_RE) = b_use('Model.FreikometerUploadList')->FOLDER_LC . '%';

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => [[qw(RealmOwner.realm_id RealmUser.user_id)]],
	order_by => [
	    'RealmOwner.name',
	    'RealmOwner.display_name',
	    {
		name => 'modified_date_time',
		type => 'DateTime',
		in_select => 1,
		select_value => qq{(SELECT
                    @{[b_use('Type.DateTime')->from_sql_value('MAX(realm_file_t.modified_date_time)')]}
                    FROM realm_file_t
                    WHERE realm_file_t.realm_id = realm_owner_t.realm_id
                    AND realm_file_t.is_folder = 0
                    AND realm_file_t.path_lc LIKE '$_FOLDER_RE'
                ) AS modified_date_time},
	    },
	],
	group_by => [
	    'RealmOwner.realm_id',
	    'RealmOwner.name',
	    'RealmOwner.display_name',
	],
	other => [
	    ['RealmUser.role', ['FREIKOMETER']],
	    $self->field_decl(
		[qw(
		    RealmUser.role
		    RealmUser.realm_id
		)],
		{in_select => 0},
	    ),
	],
    });
}

1;
