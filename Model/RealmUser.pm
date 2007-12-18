# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RealmUser;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FREIKER) = __PACKAGE__->use('Auth.Role')->FREIKER;

sub create_freiker {
    my($self, $user_id) = @_;
    return $self->create({
	user_id => $user_id,
	role => $_FREIKER,
    });
}

sub create_freiker_unless_exists {
    my($self, $user_id) = @_;
    my($v) = {
	user_id => $user_id,
	role => $_FREIKER,
	realm_id => $self->req('auth_id'),
    };
    return $self->unauth_load($v) ? () : $self->create($v);
}

sub family_id_for_freiker {
    my($self, $user_id) = @_;
    my($req) = $self->req;
    return $req->with_user($user_id, sub {
	return $req->map_user_realms(
	    sub {shift->{'RealmUser.realm_id'}},
	    {
		'RealmUser.role' => Bivio::Auth::Role->FREIKER,
		'RealmOwner.realm_type' => Bivio::Auth::RealmType->USER,
	    },
	)->[0];
    });
    return;
}

sub find_club_id_for_freiker {
    my($self, $user_id) = @_;
    return $self->map_iterate(
	sub {
	    my($ro) = $self->new_other('RealmOwner')->unauth_load_or_die({
		realm_id => shift->get('realm_id'),
	    });
	    return $ro->get('realm_type')->eq_club ? $ro->get('realm_id') : ();
	},
	'unauth_iterate_start',
	# Most recent entry is probably most relevant
	'creation_date_time desc',
	{
	    user_id => $user_id,
	    role => $_FREIKER,
	},
    )->[0] || $self->throw_die(MODEL_NOT_FOUND => {
	entity => $user_id,
	message => 'no club found',
    });
}

sub is_registered_freiker {
    my($self, $user_id) = @_;
    # Freikers are members of more than one realm (club and user)
    return @{$self->map_iterate(
	sub {1},
	'unauth_iterate_start',
	'realm_id',
	{
	    user_id => $user_id,
	    role => $_FREIKER,
	},
    )} > 1 ? 1 : 0;
}

1;
