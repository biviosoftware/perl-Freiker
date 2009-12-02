# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RideImportForm;
use strict;
use Bivio::Base 'Model.CSVImportForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_D) = __PACKAGE__->use('Type.Date');
my($_EPC) = __PACKAGE__->use('Type.EPC');
my($_T) = __PACKAGE__->use('Type.Time');

sub COLUMNS {
    return [
	[qw(epc EPC NOT_NULL)],
	[qw(datetime DateTime NOT_NULL)],
    ];
}

sub execute_ok {
    my($self) = @_;
    $self->[$_IDI] = undef;
    return shift->SUPER::execute_ok(@_);
}

sub process_record {
    my($self, $row, $count) = b_debug(@_);
    my($fields) = $self->[$_IDI] ||= _init_fields($self);
    my($v) = b_debug({
	ride_date => $_D->from_datetime($row->{datetime}),
	user_id => _user_id($self, $row->{epc}, $count) || return,
    });
    my($r) = $self->new_other('Ride');
    if ($r->unauth_load($v)) {
	return if $r->get('ride_upload_id');
	$r->unauth_delete;
    }
    $r->create({
	%$v,
	ride_time => $_T->from_datetime($row->{datetime}),
	ride_upload_id => $fields->{ride_upload_id} ||=
	    $self->new_other('RideUpload')->create({})->get('ride_upload_id'),
    });
    return;
}

sub _init_fields {
    my($self) = @_;
    $self->new_other('Lock')->acquire_unless_exists;
    return {
	fcl => $self->new_other('FreikerCodeList')->load_all,
    };
}

sub _user_id {
    my($self, $epc, $count) = @_;
    my($fields) = $self->[$_IDI];
    return $self->internal_source_error($count, $epc . ': EPC not found')
	unless my $l = $fields->{fcl}->find_row_by_epc($epc);
    return $l->get('FreikerCode.user_id');
}

1;
