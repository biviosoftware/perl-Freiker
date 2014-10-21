# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubList;
use strict;
use base 'Bivio::Biz::ListModel';


sub find_row_by_id {
    return shift->find_row_by('Club.club_id', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	order_by => [
	    'RealmOwner.display_name',
	    'Address.zip',
	],
	primary_key => [[qw(Club.club_id RealmOwner.realm_id Address.realm_id)]],
    });
}

1;
