# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerUpload;
use strict;
use Bivio::Base 'Bivio::Biz::Action';
use Bivio::IO::Log;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_D) = __PACKAGE__->use('Type.Date');
my($_RF) = __PACKAGE__->use('Action.RealmFile');

sub execute {
    my($proto, $req) = @_;
    return
	unless $req->is_http_method('put');
    Bivio::Biz::Model->new($req, 'RealmUser')->set_realm_for_freikometer;
    my($pi) = $_FP->get_clean_tail($req->get('path_info'));
    Bivio::IO::Log->write_compressed(
	File::Spec->catfile(
	    $req->get('auth_user')->get('name'),
	    $_DT->local_now_as_file_name . '-' . $pi,
	),
	$req->get_content,
	$req,
    );
    Bivio::Biz::Model->new($req, 'RideImportForm')->process_content
        if $pi =~ /\.csv$/;
    $req->set_realm($req->get('auth_user'));
    $req->put(path_info => "/upload/$pi");
    return $_RF->execute_put($req);
}

1;
