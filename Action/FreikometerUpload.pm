# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerUpload;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    my($m) = uc($req->get('r')->method);
    return _reply($req, HTTP_NOT_IMPLEMENTED => "$m: method unsupported")
	unless $m eq 'PUT';
    my($r) = $req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{
#TODO: Uncomment after 5/1/07
#	    'RealmOwner.realm_type' =>  Bivio::Auth::RealmType->CLUB,
	    'RealmUser.role' => Bivio::Auth::Role->FREIKOMETER,
	},
    );
    return _reply($req, FORBIDDEN => 'user not a freikometer')
	unless @$r;
    Bivio::Die->die($r, ': too many realms found')
	if @$r > 1;
    $req->with_realm($r->[0], sub {
	_reply(
	    $req,
	    HTTP_OK => 'Rides imported: ' .
	    Bivio::Biz::Model->new($req, 'Ride')->import_csv($req->get_content),
	);
    });
    return;
}

sub _reply {
    my($req, $status, $msg) = @_;
    my($n) = Bivio::Ext::ApacheConstants->$status();
    Bivio::IO::Alert->warn($status, ': ', $msg, ' ', $req)
        if $msg;
    $req->get('reply')->set_http_status($n)
	->set_output_type('text/plain')
	->set_output(\("$n $status\n"));
    return 1;
}

1;
