# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerDownload;
use strict;
use Bivio::Base 'Action.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FOLDER_RE) = qr{^\Q@{[
    Bivio::Biz::Model->get_instance('FreikometerDownloadList')->FOLDER
]}/}o;
sub execute_get {
    my($proto, $req, @rest) = @_;
    my(@res) = $proto->SUPER::access_controlled_execute($req, @rest);
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    my($pi) = $req->get('path_info');
    $req->throw_die(CORRUPT_QUERY => {
	message => 'not in download folder',
	entity => $pi,
    }) unless $pi =~ $_FOLDER_RE;
    $rf->delete({path => $pi});
    return @res;
}

sub execute_redirect_next_get {
    my($proto, $req) = @_;
    my($l) = Bivio::Biz::Model->new($req, 'FreikometerDownloadList')
        ->load_page({count => 1});
    return {
	method => 'client_redirect',
	task_id => 'BOT_FREIKOMETER_DOWNLOAD',
	query => undef,
	path_info => $l->set_cursor_or_die(0)->get('RealmFile.path'),
    } if $l->get_result_set_size > 0;
    return;
}

1;
