# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::RideImportForm;
use strict;
use Bivio::Base 'Model.CSVImportForm';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_D) = b_use('Type.Date');
my($_T) = b_use('Type.Time');
my($_A) = b_use('IO.Alert');
my($_TZ) = b_use('Type.TimeZone');
my($_RT) = b_use('Type.RideType');

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
    my($self, $row, $count) = @_;
    my($fields) = $self->[$_IDI] ||= _init_fields($self);
    my($dt) = $fields->{tz}->date_time_from_utc($row->{datetime});
    my($uid) = _user_id($self, $row->{epc}, $count) || return;
    my($v) = {
	ride_date => $_D->from_datetime($dt),
	user_id => $uid,
    };
    my($r) = $self->new_other('Ride');
    if ($r->unauth_load($v)) {
	return if $r->get('ride_upload_id');
	$r->unauth_delete;
    }
    $r->create({
	%$v,
	ride_type => $_RT->row_tag_get($uid, $self->req),
	ride_time => $_T->from_datetime($dt),
	ride_upload_id => $fields->{ride_upload_id} ||=
	    $self->new_other('RideUpload')->create({})->get('ride_upload_id'),
	club_id => $self->req('auth_id'),
    });
    return;
}

sub _init_fields {
    my($self) = @_;
    $self->new_other('Lock')->acquire_unless_exists;
    return {
	fcl => $self->new_other('FreikerCodeList')->load_all,
	tz => $_TZ->row_tag_get($self->req),
    };
}

sub _user_id {
    my($self, $epc, $count) = @_;
    my($fields) = $self->[$_IDI];
    my($l) = $fields->{fcl}->find_row_by_epc($epc);
    return $l->get('FreikerCode.user_id')
	if $l;
    $_A->warn_exactly_once($epc, ': not found; ', $self->req('auth_user'));
    return;
}

1;
