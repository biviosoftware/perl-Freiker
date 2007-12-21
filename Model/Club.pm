# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Club;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ADMIN) = __PACKAGE__->use('Auth.Role')->ADMINISTRATOR;
my($_GENERAL) = __PACKAGE__->use('Auth.Realm')->get_general->get('id');
my($_RN) = __PACKAGE__->use('Type.RealmName');

sub assert_freikometer_and_realm {
    my($self) = @_;
    my($req) = $self->req;
    $req->throw_die(FORBIDDEN => {
	entity => $req->get('auth_realm'),
    }) unless grep($_->eq_freikometer, @{$req->get_auth_roles});
    return;
}

sub create_realm {
    my($self, $admin_id, $display_name, $address, $website, $club_size) = @_;
    my(undef, $ro) = $self->SUPER::create_realm(
	{},
	{
	    name => $_RN->from_display_name_and_zip($display_name, $address->{zip}),
	    display_name => $display_name,
	},
	$admin_id,
    );
    my($req) = $self->req;
    $req->set_realm($ro);
    my($cid) = $self->get('club_id');
    $self->new_other('Address')->create({
	%$address,
	realm_id => $cid,
    });
    $self->new_other('Website')->create({
	%$website,
	realm_id => $cid,
    });
    $self->new_other('RowTag')->replace_value($cid, CLUB_SIZE => $club_size);
    foreach my $u (@{$self->new_other('RealmAdminList')->map_iterate(
	sub {shift->get('RealmUser.user_id')},
	'unauth_iterate_start',
	{auth_id =>  $_GENERAL},
    )}) {
	$self->new_other('RealmUser')->create({
	    user_id => $u,
	    role => $_ADMIN,
	    realm_id => $cid,
	});
    }
    return $self;
}

sub _die {
    my($req, $die, $msg) = @_;
    Bivio::IO::Alert->warn($die, ': ', $msg, ' ', $req);
    Bivio::Die->throw_quietly($die);
    # DOES NOT RETURN
}

1;
