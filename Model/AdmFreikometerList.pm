# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmFreikometerList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => [[qw(RealmOwner.realm_id RealmUser.user_id RealmFile.realm_id)]],
	order_by => [
	    'RealmOwner.name',
	    'RealmFile.modified_date_time',
	],
	other => [
	    ['RealmUser.role', ['FREIKOMETER']],
#TODO: need a max time on upload recursively
	    ['RealmFile.path_lc', [
		$self->get_instance('FreikometerUploadList')->FOLDER_LC]],
	],
    });
}

1;
