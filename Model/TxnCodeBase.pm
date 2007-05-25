# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::TxnCodeBase;
use strict;
use Bivio::Base 'Model.RealmBase';
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    distributor => Freiker::Test->DISTRIBUTOR_NAME,
});

sub create {
    my($self, $values) = @_;
    my($field) = $self->TXN_CODE_FIELD;
    $self->get_request->with_realm($_CFG->{distributor} => sub {
        my($ft) = $self->get_field_type($field);
	$self->new_other('Lock')->acquire_unless_exists;
	my($codes) = $self->map_iterate(sub {shift->get($field)}, $field);
	do {
	    $values->{$field} = $ft->generate_random;
	} while grep($_ eq $values->{$field}, @$codes);
    }) unless $values->{$field};
    return shift->SUPER::create(@_);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

1;
