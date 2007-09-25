# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::HomeRedirect;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    return 'adm_task'
	if $req->is_super_user;
    $req->set_realm($req->get('auth_user'));
    my($m) = Bivio::Biz::Model->new($req, 'UserRealmList')->load_all;
    if ($m->find_row_by_type(Bivio::Auth::RealmType->FORUM)
        || $m->find_row_by_type(Bivio::Auth::RealmType->CLUB)
    ) {
	$req->set_realm($m->get('RealmUser.realm_id'));
# 	return 'merchant_task'
# 	    if $req->get_nested(qw(auth_realm type))->eq_forum;
	return 'wheel_task'
	    if $m->get('RealmUser.role')->eq_administrator;
    }
    $req->set_realm($req->get('auth_user_id'));
    return 'family_task';
}

1;
