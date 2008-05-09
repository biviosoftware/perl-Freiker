# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RealmOwnerBase;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = __PACKAGE__->use('Auth.Role');

sub internal_create_realm_administrator_id {
    return;
}

sub create_realm {
    my($self, $realm_owner, $admin_id) = @_;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => $self->REALM_TYPE,
	realm_id => $self->get_primary_id,
    });
    $admin_id ||= $self->internal_create_realm_administrator_id;
    $self->new_other('RealmUser')->create({
	realm_id => $self->get_primary_id,
	user_id => $admin_id,
        role => $_R->ADMINISTRATOR,
    }) if $admin_id;
    return ($self, $ro);
}

1;
