# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GreenGearList;
use strict;
use Bivio::Base 'Model.ClubFreikerList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LOCATION) = b_use('Model.Address')->DEFAULT_LOCATION;

sub internal_initialize {
    my($self) = @_;
    my($super) = $self->SUPER::internal_initialize;
    unshift(@{$super->{order_by}}, qw(
	GreenGear.begin_date
	GreenGear.end_date
	GreenGear.creation_date_time
    ));
    push(@{$super->{group_by}}, qw(
	GreenGear.green_gear_id
	GreenGear.begin_date
	GreenGear.end_date
	GreenGear.creation_date_time
    ));
    return $self->merge_initialize_info($super, {
        version => 1,
        other => [
	    [qw(RealmUser.user_id GreenGear.user_id)],
	    [qw(RealmUser.realm_id GreenGear.club_id)],
	],
    });
}

1;
