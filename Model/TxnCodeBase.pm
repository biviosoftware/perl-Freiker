# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::TxnCodeBase;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TC) = Bivio::Type->get_instance('TxnCode');

sub create {
    my($self, $values) = @_;
    my($field) = $self->TXN_CODE_FIELD;
    unless ($values->{$field}) {
	$self->new_other('Lock')->acquire_unless_exists;
	my($codes) = $self->map_iterate(sub {shift->get($field)}, $field);
	do {
	    $values->{$field} = $_TC->generate_random;
	} while grep($_ eq $values->{$field}, @$codes);
    }
    return shift->SUPER::create(@_);
}

1;
