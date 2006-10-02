# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubSelectList;
use strict;
use base 'Freiker::Model::ClubList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_load {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_load(@_);
    unshift(
	@{$self->internal_get_rows},
	{
	    map(($_ => undef), @{$self->get_keys}),
	    'RealmOwner.display_name' => 'Select School',
	    'Club.club_id' => $self->EMPTY_KEY_VALUE,
	},
    );
    return @res;
}

1;
