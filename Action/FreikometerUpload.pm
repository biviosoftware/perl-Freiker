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
    return _reply($req, FORBIDDEN => "user not a freikometer")
	unless grep($_->eq_freikometer, @{$req->get('auth_roles')});
    Bivio::Biz::Model->new($req, 'Ride')->import_csv($req->get_content);
    return 1;
}

sub _reply {
    my($req, $status, $msg) = @_;
    my($n) = Bivio::Ext::ApacheConstants->$status();
    Bivio::IO::Alert->warn($status, ': ', $msg, ' ', $req)
	unless $status eq 'OK';
    $req->get('reply')->set_http_status($n)
	->set_output_type('text/plain')
	->set_output(\("$n $status\n"));
    return 1;
}

1;
