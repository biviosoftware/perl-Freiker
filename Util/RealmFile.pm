# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::RealmFile;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LQ) = b_use('SQL.ListQuery');
my($_DT) = b_use('Type.DateTime');

sub DAYS_TO_KEEP_FREIKOMETER_FILES {
    return 180;
}

sub purge_freikometer_files {
    my($self) = @_;
    my($count) = 0;
    my($realms) = {};
    $self->model('AdmFreikometerFileList')->do_iterate(
	sub {
	    my($it) = @_;
	    $realms->{$it->get('RealmFile.realm_id')} = 1;
	    my($rf) = $it->new_other('RealmFile');
	    $rf->unauth_load({
		realm_file_id => $it->get('RealmFile.realm_file_id'),
	    });
	    return 1
		if $it->get('RealmFile.is_folder');
	    $rf->delete({
		override_is_read_only => 1,
		override_versioning => 1,
	    });
	    $count++;
	    $self->commit_or_rollback
		if $count % 100 == 0;
	    $self->print_line($count)
		if $count % 10000 == 0;
	    return 1;
	},
	'unauth_iterate_start',
	{
	    $_LQ->to_char('date') => $_DT->add_days(
		$_DT->now, -$self->DAYS_TO_KEEP_FREIKOMETER_FILES),
	},
    );
    for my $r (keys(%$realms)) {
	$self->req->with_realm($r, sub {
	    $self->model('RealmFile')->delete_empty_folders;
	});
    }
    return $count;
}

1;
