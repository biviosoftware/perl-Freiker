# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCode;
use strict;
use base 'Bivio::Biz::PropertyModel';
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EPC) = Bivio::Type->get_instance('EPC');

sub import_csv {
    my($self, $csv) = @_;
    my($req) = $self->get_request;
    my($zip) = $self->new_other('Address')->load->get('zip');
    my($res) = 0;
    foreach my $row (@{Bivio::Util::CSV->parse($csv)}) {
	my($epc) = $_EPC->from_literal_or_die($row->[0]);
	Bivio::Die->die($epc->get('zip'), ': invalid zip; expected: ', $zip)
	    unless $epc->get('zip') eq $zip;
	$self->create({
	    freiker_code => $epc->get('freiker_code'),
	    club_id => $req->get('auth_id'),
	});
	$res++;
    }
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'freiker_code_t',
	columns => {
	    freiker_code => ['FreikerCode', 'PRIMARY_KEY'],
            club_id => ['Club.club_id', 'NOT_NULL'],
        },
    });
}

1;
