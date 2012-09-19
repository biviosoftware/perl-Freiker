# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::User;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Type.RideType');

sub create_freiker {
    my($self, $values_or_code) = @_;
    $values_or_code = {first_name => $values_or_code}
	unless ref($values_or_code) eq 'HASH';
    my($uid) = ($self->create_realm($values_or_code, {}))[0]->get('user_id');
    $self->new_other('RealmUser')
	->create_freiker($uid)
	->new_other('FreikerInfo')
	->create({user_id => $uid})
	->new_other('Address')
	->create({realm_id => $uid});
    $_RT->row_tag_replace($uid, $_RT->UNKNOWN, $self->req);
    return $uid;
}

sub unauth_delete_realm {
    my($self, $user_id) = @_;
    if ($user_id) {
	return unless $self->unauth_load({user_id => $user_id});
    }
    elsif (!$self->is_loaded) {
	$self->die('must supply user_id or is_loaded');
    }
    $self->req->with_realm($self->get('user_id'), sub {
	$self->new_other('RealmUser')->do_iterate(
	    sub {
	        shift->delete;
	        return 1;
	    },
	    'unauth_iterate_start',
	    'realm_id',
	    {user_id => $self->get('user_id')},
	);
	$self->cascade_delete;
	return;
    });
    return;
}

1;
