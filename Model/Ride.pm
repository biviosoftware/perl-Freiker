# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Ride;
use strict;
use Bivio::Base 'Model.RealmBase';
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');
my($_T) = Bivio::Type->get_instance('Time');
my($_EPC) = Bivio::Type->get_instance('EPC');
my($_NO_TIME) = $_T->time_from_parts(0, 0, 0);

sub CSV_HEADER {
    return "EPC,DateTime";
}

sub create {
    my($self, $values) = @_;
    $values->{ride_time} ||= $_NO_TIME;
    $values->{is_manual_entry} = 1
	unless defined($values->{is_manual_entry});
    return shift->SUPER::create(@_);
}

sub import_csv {
    my($self, $csv) = @_;
    my($req) = $self->get_request;
    my($rows) = Bivio::Util::CSV->parse($csv);
    my($row) = shift(@$rows);
    Bivio::Die->die($row, ': expected to be: ', $self->CSV_HEADER)
        unless join(',', @$row) eq $self->CSV_HEADER;
    $self->new_other('Lock')->acquire;
    my($zip) = $self->new_other('Address')->load->get('zip');
    my($fcl) = $self->new_other('FreikerCodeList')->load_all;
    my($res) = 0;
    foreach my $row (@$rows) {
	my($epc) = $_EPC->from_literal_or_die($row->[0]);
	Bivio::Die->die($epc->get('zip'), ': invalid zip; expected: ', $zip)
	    unless $epc->get('zip') eq $zip;
	my($fc) = $epc->get('freiker_code');
	Bivio::Die->die(
	    $epc, ': Freiker code not found in ', $req->get('auth_realm')
	) unless $fcl->find_row_by_code($fc);
	Bivio::Die->die($row->[1], ': bad date time')
	    unless my($d, $t) = $row->[1] =~ /^(\d{8})(\d{6})$/;
	my($v) = {
	    ride_date => $_D->from_literal_or_die($d),
	    freiker_code => $fc,
	};
	next if $self->unauth_load($v);
	$self->create({
	    %$v,
	    # realm_id defaults to club if there's no Ride.realm_id
	    realm_id => $fcl->unsafe_get('Ride.realm_id'),
	    ride_time => $_T->from_literal_or_die($t),
	    is_manual_entry => 0,
	});
	$res++;
    }
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'ride_t',
	columns => {
	    freiker_code => ['FreikerCode', 'PRIMARY_KEY'],
            ride_date => ['Date', 'PRIMARY_KEY'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
	    ride_time => ['Time', 'NOT_NULL'],
	    is_manual_entry => ['Boolean', 'NOT_NULL'],
        },
    });
}

1;
