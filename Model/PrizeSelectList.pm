# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeSelectList;
use strict;
use Bivio::Base 'Model.ClubPrizeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_DD) = __PACKAGE__->use('Model.TxnCodeBase')->DEFAULT_DISTRIBUTOR;

sub FREIKER_LIST {
    return 'FreikerList';
}

sub execute_load_for_drilldown {
    my($proto, $req) = @_;
    $proto->new($req)->load_from_drilldown;
    return;
}

sub execute_load_for_user_and_credit {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->new_other($self->FREIKER_LIST)
	->load_this({this => $self->parse_query_from_request->get('parent_id')});
    return;
}

sub get_distributor_id {
    my($self) = @_;
    return $self->new_other('RealmOwner')
	->unauth_load_or_die({name => $_DD})
	->get('realm_id');
}

sub get_prize_credit {
    return shift->[$_IDI];
}

sub load_for_user_and_credit {
    my($self, $user_id, $prize_credit) = @_;
    return $self->unauth_load_all({
	parent_id => $user_id,
	prize_credit => $prize_credit,
	auth_id => $self->new_other('RealmUser')->club_id_for_freiker($user_id),
    })
}

sub get_query_for_this {
    my($self) = @_;
    return {
        Bivio::SQL::ListQuery->to_char('parent_id')
	    => $self->get('RealmUser.user_id'),
        Bivio::SQL::ListQuery->to_char('this') => $self->get('Prize.prize_id'),
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	parent_id => ['User.user_id'],
	other_query_keys => [qw(prize_credit)],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    # So doesn't show up with format_uri
    my($pc) = $self->[$_IDI] = $query->get('prize_credit');
    $query->delete('prize_credit');
    $stmt->where(
	$stmt->EQ('PrizeRideCount.realm_id', [
	    $self->new_other('RealmUser')
		->club_id_for_freiker($query->get('parent_id')),
	]),
	$stmt->GT('PrizeRideCount.ride_count', [0]),
	$stmt->LTE(
	    'PrizeRideCount.ride_count', [$pc]),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub load_from_drilldown {
    my($self, $query) = @_;
    $query = $query ? $self->parse_query($query)
	: $self->parse_query_from_request;
    my($fl) = $self->new_other($self->FREIKER_LIST)
	->load_this({this => $query->get('parent_id')});
    return
	unless $fl->get('can_select_prize');
    $self = $fl->get('prize_select_list');
    my($pid) = $query->get('this')->[0];
    $self->throw_die(MODEL_NOT_FOUND => {
	message => 'prize not selectable',
	entity => $pid,
	user_id => $fl->get('RealmUser.user_id'),
    }) unless $self->find_row_by('Prize.prize_id' => $pid);
    return $self;
}

1;
