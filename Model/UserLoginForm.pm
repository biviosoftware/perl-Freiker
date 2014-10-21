# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::UserLoginForm;
use strict;
use Bivio::Base 'Model';

my($_FC) = __PACKAGE__->use('Type.FreikerCode');

sub internal_validate_login_value {
    my($self, $value) = @_;
    my($realm, $err) = $self->SUPER::internal_validate_login_value($value);
    return ($realm, $err)
	if $realm || !($value = ($_FC->from_literal($value))[0]);
    my($fc) = $self->new_other('FreikerCode');
    return ($realm, $err)
	unless $fc->unauth_load({freiker_code => $value});
    return (undef, Bivio::TypeError->OFFLINE_USER)
	unless my $rid = $self->new_other('RealmUser')
	    ->unsafe_family_id_for_freiker($fc->get('user_id'));
    return ($self->new_other('RealmOwner')
        ->unauth_load_or_die({realm_id => $rid}),
	undef);

}

1;
