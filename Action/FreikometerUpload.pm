# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerUpload;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_FP) = b_use('Type.FilePath');
my($_D) = b_use('Type.Date');
my($_RF) = b_use('Action.RealmFile');
my($_L) = b_use('IO.Log');
my($_M) = b_use('Biz.Model');

sub execute {
    my($proto, $req) = @_;
    return
	unless $req->is_http_method('put');
    $_M->new($req, 'RealmUser')->set_realm_for_freikometer;
    my($pi) = $_FP->get_clean_tail($req->get('path_info'));
    $_L->write_compressed(
	File::Spec->catfile(
	    $req->get('auth_user')->get('name'),
	    $_DT->local_now_as_file_name . '-' . $pi,
	),
	$req->get_content,
	$req,
    );
    $_M->new($req, 'RideImportForm')->process_content
        if $pi =~ /\.csv$/;
    $req->set_realm($req->get('auth_user'));
    $req->put(path_info => "/upload/$pi");
    $_RF->execute_put($req);
    $proto->reply_header_out(
	'X-FreikometerUpload', length(${$req->get_content}), $req);
    return;
}

sub reply_header_out {
    my(undef, $key, $value, $req) = @_;
    $req->get('r')->header_out($key, $value);
    return;
}

1;
