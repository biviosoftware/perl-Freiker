# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmFreikometerFileList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => ['RealmFile.realm_file_id'],
        order_by => [
	    'RealmFile.modified_date_time',
	],
	other => [
	    ['RealmUser.role', ['FREIKOMETER']],
	    [qw(RealmFile.realm_id RealmUser.user_id)],
	    'RealmFile.path_lc',
	    'RealmFile.is_folder',
	],
	auth_id => 'RealmFile.realm_id',
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->AND(
	    $stmt->LT('RealmFile.modified_date_time',
		      [$query->unsafe_get('date') || $_DT->now]),
	    $stmt->GT('RealmFile.modified_date_time',
		      [$query->unsafe_get('begin_date') || $_DT->get_min]),
	),
    );
    return;
}

1;
