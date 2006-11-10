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
    foreach my $r (values(%{$req->get_user_realms})) {
	next unless $r->{'RealmOwner.realm_type'}->eq_club
	    && $r->{'RealmUser.role'}->eq_freikometer;
	$req->set_realm($r->{'RealmOwner.name'});
	return _reply(
	    $req,
	    HTTP_OK => 'Rides imported: ' .
	    Bivio::Biz::Model->new($req, 'Ride')->import_csv($req->get_content),
	);
    }
    return _reply($req, FORBIDDEN => 'user not a freikometer');
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
