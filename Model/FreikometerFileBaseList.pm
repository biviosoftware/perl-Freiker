# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikometerFileBaseList;
use strict;
use Bivio::Base 'Model.RealmFileList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub FOLDER_LC {
    return lc(shift->FOLDER);
}

sub internal_initialize {
    my($self) = @_;
    my($parent) = $self->SUPER::internal_initialize;
    push(@{$parent->{other} ||= []}, @{$parent->{order_by} || []});
    return $self->merge_initialize_info($parent, {
        version => 1,
        order_by => [
	    {
		name => 'RealmFile.modified_date_time',
		sort_order => 1,
	    },
	    {
		name => 'RealmFile.realm_file_id',
		sort_order => 1,
	    },
	],
    });
}

sub internal_pre_load {
    my($self, $query) = @_;
    $query->put(path_info => $self->FOLDER_LC);
    return shift->SUPER::internal_pre_load(@_);
}

1;
