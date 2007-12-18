# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Club;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub assert_freikometer_and_realm {
    my($self) = @_;
    my($req) = $self->req;
    $req->throw_die(FORBIDDEN => {
	entity => $req->get('auth_realm'),
    }) unless grep($_->eq_freikometer, @{$req->get_auth_roles});
    return;
}

sub set_freikometer_for_realm {
    my($self) = @_;
    $self->req->set_user(
	$self->new_other('FreikometerList')
	    ->load_all->get('RealmOwner.realm_id'),
    );
    return $self;
}

sub set_realm_for_freikometer {
    my($self) = @_;
    my($req) = $self->req;
    my($r) = $req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{
	    'RealmOwner.realm_type' =>  Bivio::Auth::RealmType->CLUB,
	    'RealmUser.role' => Bivio::Auth::Role->FREIKOMETER,
	},
    );
    _die($req, FORBIDDEN => 'user not a freikometer')
	unless @$r;
    _die($req, INVALID_OP => "@$r: too many realms found")
	if @$r > 1;
    $req->set_realm($r->[0]);
    return $self;
}

sub _die {
    my($req, $die, $msg) = @_;
    Bivio::IO::Alert->warn($die, ': ', $msg, ' ', $req);
    Bivio::Die->throw_quietly($die);
    # DOES NOT RETURN
}

1;
