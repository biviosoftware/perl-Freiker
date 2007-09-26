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

sub execute {
    my($proto, $req) = @_;
    return
	unless $req->is_http_method('put');
    my($r) = $req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{
	    'RealmOwner.realm_type' =>  Bivio::Auth::RealmType->CLUB,
	    'RealmUser.role' => Bivio::Auth::Role->FREIKOMETER,
	},
    );
    _die($req, FORBIDDEN => 'user not a freikometer')
	unless @$r;
    _die($req, INVALID_OP => "@$r: too many realms found")
	if @$r > 1;
    $req->set_realm($r->[0]);
    my($pi) = $req->get('path_info');
    # Old upload.PL used /fm/upload
    $pi = $_D->to_file_name($_D->local_today) . '.csv'
	if $pi eq '/upload';
    Bivio::IO::Log->write_compressed(
	File::Spec->catfile(
	    $req->get('auth_user')->get('name'),
	    $_DT->local_now_as_file_name . '-' . $_FP->get_clean_tail($pi)
	),
	$req->get_content,
	$req,
    );
    Bivio::Biz::Model->new($req, 'Ride')->import_csv($req->get_content)
        if $pi =~ /\.csv$/;
    $req->set_realm($req->get('auth_user'));
    $req->put(path_info => "/upload/$pi");
    $proto->get_instance('RealmFile')->execute_put($req);
    return;
}

sub _die {
    my($req, $die, $msg) = @_;
    Bivio::IO::Alert->warn($die, ': ', $msg, ' ', $req);
    Bivio::Die->throw_quietly($die);
    # DOES NOT RETURN
}

1;
