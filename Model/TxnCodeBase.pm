# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::TxnCodeBase;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub DEFAULT_DISTRIBUTOR {
    return 'freiker803042435';
}

sub create {
    my($self, $values) = @_;
    my($field) = $self->TXN_CODE_FIELD;
    $self->get_request->with_realm($self->DEFAULT_DISTRIBUTOR => sub {
        my($ft) = $self->get_field_type($field);
	$self->new_other('Lock')->acquire_unless_exists;
	my($codes) = $self->map_iterate(sub {shift->get($field)}, $field);
	do {
	    $values->{$field} = $ft->generate_random;
	} while grep($_ eq $values->{$field}, @$codes);
    }) unless $values->{$field};
    return shift->SUPER::create(@_);
}

1;
