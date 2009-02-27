# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GreenGearList;
use strict;
use Bivio::Base 'Model.ClubFreikerList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    my($super) = $self->SUPER::internal_initialize;
    unshift(@{$super->{order_by}}, qw(
	GreenGear.begin_date
	GreenGear.end_date
	GreenGear.creation_date_time
    ));
    return $self->merge_initialize_info($super, {
        version => 1,
        other => [
	    'GreenGear.must_be_registered',
	    'GreenGear.must_be_unique',
	    [qw(RealmUser.user_id GreenGear.user_id)],
	    [qw(RealmUser.realm_id GreenGear.club_id)],
	],
    });
}

1;
