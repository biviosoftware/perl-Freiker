# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RealmUser;
use strict;
use Bivio::Base 'Model';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FREIKER) = __PACKAGE__->use('Auth.Role')->FREIKER;
my($_FREIKOMETER) = $_FREIKER->FREIKOMETER;
my($_CLUB) = __PACKAGE__->use('Auth.RealmType')->CLUB;
my($_USER) = $_CLUB->USER;
our($_TRACE);

sub club_id_for_freiker {
    return _club_id(user_id => @_);
}

sub club_id_for_freiker_code {
    return _club_id(freiker_code => @_);
}

sub create_freiker {
    my($self, $user_id) = @_;
    return $self->create({
	user_id => $user_id,
	role => $_FREIKER,
    });
}

sub create_freiker_unless_exists {
    my($self, $user_id, $realm_id) = @_;
    my($v) = {
	user_id => $user_id,
	role => $_FREIKER,
	realm_id => $realm_id,
    };
    return $self->create($v)
	unless $self->unauth_load($v);
    return $self;
}

sub is_registered_freiker {
    return shift->unsafe_family_id_for_freiker(@_) ? 1 : 0;
}

sub set_freikometer_for_realm {
    my($self) = @_;
    $self->req->set_user(
	$self->new_other('FreikometerList')
	    ->load_all
	    ->set_cursor_or_not_found(0)
	    ->get('RealmOwner.realm_id'),
    );
    return;
}

sub set_realm_for_freikometer {
    my($self) = @_;
    my($req) = $self->req;
    my($r) = $req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{
	    'RealmOwner.realm_type' =>  $_CLUB,
	    'RealmUser.role' => $_FREIKOMETER,
	},
    );
    $req->throw_die(FORBIDDEN => {message => 'user not a freikometer'})
	unless @$r;
    $req->throw_die(INVALID_OP => {message => "@$r: too many realms found"})
	if @$r > 1;
    $req->set_realm($r->[0]);
    return;
}

sub unsafe_family_id_for_freiker {
    my($self, $user_id) = @_;
    return $self->new_other('FreikerRealmList')->map_iterate(
	sub {
	    my($it) = @_;
	    return $it->get('RealmOwner_2.realm_type')->eq_user
		? shift->get('RealmUser.realm_id') : ();
	},
	'unauth_iterate_start',
	{auth_id => $user_id},
    )->[0];
}

sub _club_id {
    my($which, $self, $value) = @_;
    return $self->new_other('FreikerCode')->map_iterate(
	sub {shift->get('club_id')},
	'unauth_iterate_start',
	# Most recent entry is probably most relevant
	'modified_date_time desc',
	{$which => $value},
    )->[0] || _not_freiker($self, $which, $value);
}

sub _not_freiker {
    my($self, $which, $value) = @_;
    $self->throw_die(MODEL_NOT_FOUND => {
	entity => $value,
	message => "$which: not a freiker",
    });
    # DOES NOT RETURN
}

1;
