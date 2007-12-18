# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeImportForm;
use strict;
use Bivio::Base 'Model.CSVImportForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub COLUMNS {
    return [
	[qw(epc FreikerCode.epc)],
	[qw(print FreikerCode.freiker_code)],
    ];
}

sub process_record {
    my($self, $row) = @_;
    $self->new_other('FreikerCode')
	->create_from_epc_and_code(@{$row}{qw(epc print)});
    return;
}

1;
