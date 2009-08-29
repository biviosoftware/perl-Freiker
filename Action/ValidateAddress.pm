# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::ValidateAddress;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MA) = b_use('Model.Address');
my($_AA) = b_use('Action.Acknowledgement');

sub execute {
    my($proto, $req) = @_;
    my($addr) = $_MA->new($req);
    return {
	task_id => 'USER_SETTINGS_FORM',
	query => $_AA->save_label('update_address', $req, {}),
    } unless $addr->unsafe_load && $addr->get('zip') && $addr->get('country');
    my($uid);
    $req->get('Model.FreikerList')->do_rows(sub {
        my($it) = @_;
	return 1
	    if $addr->unauth_load({realm_id => $it->get('RealmUser.user_id')})
	    && $addr->get('street2');
	$uid = $it->get('RealmUser.user_id');
	return 0;
    })->reset_cursor;
    return {
	task_id => 'FAMILY_FREIKER_EDIT',
	query => $_AA->save_label('update_address', $req, {
	    'ListQuery.parent_id' => $uid,
	}),
    } if $uid;
    return 0;
}

1;
