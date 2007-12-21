# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
    return 10_000;
}

sub find_row_by_code {
    return shift->find_row_by('FreikerCode.freiker_code', shift);
}

sub find_row_by_epc {
    return shift->find_row_by('FreikerCode.epc', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => ['FreikerCode.freiker_code'],
	auth_id => 'FreikerCode.club_id',
	order_by => [qw(
            FreikerCode.freiker_code
	)],
	other => [qw(
            FreikerCode.epc
            FreikerCode.user_id
        )],
    });
}

1;
