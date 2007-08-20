# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RealmUser;
use strict;
use Bivio::Base 'Bivio::Biz::Model::RealmUser';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub find_club_id {
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
	'creation_date_time asc',
	{
	    user_id => $user_id,
	    role => Bivio::Auth::Role->MEMBER,
	},
    )->[0] || $self->throw_die(MODEL_NOT_FOUND => {
	entity => $user_id,
	message => 'no club found',
    });
}

1;
