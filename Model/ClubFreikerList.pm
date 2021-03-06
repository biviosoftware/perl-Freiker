# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerList;
use strict;
use Bivio::Base 'Model.FreikerList';

my($_IDI) = __PACKAGE__->instance_data_index;

sub LOAD_ALL_SIZE {
    return 100_000;
}

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

sub PRIZE_SELECT_LIST {
    return 'ClubPrizeSelectList';
}

sub internal_can_select_prize {
#TODO: Not needed for clubs b/c no drilldown;  There's a bug
#      in the date filtering in FreikerList where a PrizeRideCount.ride_count
#      comes up negative in a particular situation
    my($self, $row) = @_;
    return $self->get_query->unsafe_get('this')
	? shift->SUPER::internal_can_select_prize(@_) : 0;
}

sub internal_freiker_codes {
    my($self, $row) = @_;
    return (
	$self->[$_IDI]->{code_list}
	    ||= $self->new('FreikerCodeUserList')->load_all
    )->freiker_codes_for_user($row->{'RealmUser.user_id'});
}

sub internal_pre_load {
    my($self) = @_;
    $self->[$_IDI] = {};
    return shift->SUPER::internal_pre_load(@_);
}

1;
