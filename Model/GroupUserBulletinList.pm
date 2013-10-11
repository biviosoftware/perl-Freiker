# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GroupUserBulletinList;
use strict;
use Bivio::Base 'Model.GroupUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_E) = b_use('Type.Email');
my($_F) = b_use('ShellUtil.Freikometer');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        group_by => [
	    ['Email.want_bulletin', [1]],
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    return 0
	if $_E->is_ignore($row->{'Email.email'})
	|| $_F->is_freikometer_name($row->{'RealmOwner.name'});
    return 1;
}

1;
