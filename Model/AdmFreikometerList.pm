# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmFreikometerList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FOLDER_RE) = b_use('Model.FreikometerUploadList')->FOLDER_LC . '%';

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => [[qw(RealmOwner.realm_id RealmUser.user_id RealmFile.realm_id)]],
	order_by => [
	    'RealmOwner.name',
	    'RealmOwner.display_name',
	    {
		name => 'modified_date_time',
		type => 'DateTime',
		in_select => 1,
		select_value =>
		    b_use('Type.DateTime')
		        ->from_sql_value('MAX(realm_file_t.modified_date_time)')
		        . ' AS modified_date_time',
	    },
	],
	group_by => [
	    'RealmOwner.name',
	    'RealmOwner.display_name',
	],
	other => [
	    ['RealmUser.role', ['FREIKOMETER']],
	    ['RealmFile.is_folder', [0]],
	    $self->field_decl(
		[qw(
		    RealmFile.realm_file_id
		    RealmUser.role
		    RealmUser.realm_id
		    RealmFile.is_folder
		    RealmOwner.realm_id
		)],
		{in_select => 0},
	    ),
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(
	$stmt->LIKE('RealmFile.path_lc', $_FOLDER_RE),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
