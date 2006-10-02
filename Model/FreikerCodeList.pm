# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub find_row_by_code {
    return shift->find_row_by('FreikerCode.freiker_code', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [[qw{FreikerCode.freiker_code Ride.freiker_code(+)}]],
	auth_id => 'FreikerCode.club_id',
	other => [
	    {
		name => 'Ride.ride_date',
		in_select => 0,
	    },
	],
	group_by => [qw(
            FreikerCode.freiker_code
	    Ride.realm_id
	)],
    });
}

1;
