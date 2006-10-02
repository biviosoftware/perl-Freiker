# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Type::EPC;
use strict;
use base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_PREFIX) = '000000004652';

sub as_string {
    my($self) = @_;
    return $self->to_literal($self);
}

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    return (undef, Bivio::TypeError->EPC)
	unless $value =~ /^$_PREFIX([0-9a-h]{8})([0-9a-h]{4})$/io;
    return $proto->new(hex($1), hex($2));
}

sub from_sql_column {
    die;
}

sub get {
    my($self, $attr) = @_;
    return $self->[$_IDI]->{$attr} || die($attr, ': no such attribute');
}


sub get_width {
    return 24;
}

sub new {
    my($proto, $zip, $freiker_code) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	zip => $zip,
	freiker_code => $freiker_code,
    };
    return $self;
}

sub to_literal {
    my(undef, $value) = @_;
    return !$value ? ''
	: $_PREFIX
	. sprintf("%08X%04X", map($value->get($_), qw(zip freiker_code)));
}

sub to_sql_param {
    die;
}

sub to_sql_value {
    die;
}

1;
