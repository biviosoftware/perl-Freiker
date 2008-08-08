# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerDownload;
use strict;
use Bivio::Base 'Action.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FOLDER_RE) = qr{^\Q@{[
    Bivio::Biz::Model->get_instance('FreikometerDownloadList')->FOLDER
]}/}io;
my($_FU) = b_use('Action.FreikometerUpload');
my($_M) = b_use('Biz.Model');

sub execute_get {
    my($proto, $req, @rest) = @_;
    my(@res) = $proto->SUPER::access_controlled_execute($req, @rest);
    my($rf) = $req->get('Model.RealmFile');
    $req->throw_die(CORRUPT_QUERY => {
	message => 'not in download folder',
	entity => $rf
    }) unless $rf->get('path') =~ $_FOLDER_RE;
    $_FU->reply_header_out(
	'X-FreikometerDownload', $rf->get_content_length, $req);
    $rf->delete;
    return @res;
}

sub execute_redirect_next_get {
    my($proto, $req) = @_;
    my($l) = $_M->new($req, 'FreikometerDownloadList')->load_page({count => 1});
    $_FU->reply_header_out('X-FreikometerDownload', -1, $req);
    return {
	method => 'client_redirect',
	task_id => 'BOT_FREIKOMETER_DOWNLOAD',
	query => undef,
	path_info => $l->set_cursor_or_die(0)->get('RealmFile.path'),
    } if $l->get_result_set_size > 0;
    return;
}

1;
