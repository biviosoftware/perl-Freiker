# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmSummaryBySchoolList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');

sub REALM_TYPE {
    return $_RT->CLUB;
}

sub internal_get_summary {
    my($self, $realm_id) = @_;
    $self->req->set_realm($realm_id);
    return $self->new_other('ClubFreikerList')->load_all->get_summary;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['RealmOwner.realm_id'],
	other => [
	    ['RealmOwner.realm_type', [$self->REALM_TYPE]],
	    'RealmOwner.display_name',
	    $self->field_decl([
		[qw(ride_count Integer)],
		[qw(current_miles Miles)],
		[qw(current_kilometers Kilometers)],
		[qw(calories Integer)],
		[qw(co2_saved Integer)],
	    ]),
	],
	other_query_keys => [qw(fr_begin fr_end)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($ro) = $self->new_other('RealmOwner');
    $ro->unauth_load({
	realm_id => $row->{'RealmOwner.realm_id'},
    });
    return 0
	if $ro->is_default;
    my($s) = $self->internal_get_summary($row->{'RealmOwner.realm_id'});
    map($row->{$_} = $s->get($_),
	qw(ride_count current_miles current_kilometers calories co2_saved));
    return 1;
}

1;
