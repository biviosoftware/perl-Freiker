# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::ValidateAddress;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_M) = b_use('Biz.Model');
my($_AA) = b_use('Action.Acknowledgement');
my($_D) = b_use('Bivio.Die');

sub execute {
    my($proto, $req) = @_;
    my($addr) = $_M->new($req, 'Address');
    return {
	task_id => 'USER_SETTINGS_FORM',
	query => $_AA->save_label('update_address', $req, {}),
    } unless $addr->unauth_load({realm_id => $req->get('auth_user_id')})
	&& $addr->get('zip') && $addr->get('country');
    my($uid);
    my($list) = $req->get_or_default(
	'Model.FreikerList',
	sub {
	    return $req->with_realm(
		$req->get('auth_user_id'),
		sub {
		    return $_D->eval(sub {$_M->new($req, 'FreikerList')->load_all});
		},
	    );
	},
    );
    $list->do_rows(
	sub {
	    my($it) = @_;
	    return 1
		if $addr->unauth_load({realm_id => $it->get('RealmUser.user_id')})
		&& $addr->get('zip');
	    $uid = $it->get('RealmUser.user_id');
	    return 0;
	})
	->reset_cursor
	if $list;
    return {
	task_id => 'FAMILY_FREIKER_EDIT',
	query => $_AA->save_label('update_address', $req, {
	    'ListQuery.parent_id' => $uid,
	}),
    } if $uid;
    return 0;
}

1;
