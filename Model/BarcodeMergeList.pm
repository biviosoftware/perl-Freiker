# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeMergeList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_load_all {
    my($self) = shift->new(shift);
    $self->new_other('ClassList')->load_all;
    return  $self->load_all->get_result_set_size ? 0 : 'next';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['RealmOwner.realm_id'],
	other => [qw(
	    RealmOwner.name
	    RealmOwner.display_name
	    RealmUser.realm_id
	    RealmOwner_2.name
	),
	    {
		name => 'class_name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($map) = {};
    my($e) = $self->get_instance('FreikerInfoForm')->EMPTY_NAME;
    return $self->get_request->get('Model.BarcodeList')->map_rows(
	sub {
	    my($id, $n, $d, $c) = shift->get(
		qw(RealmUser.user_id RealmOwner.name RealmOwner.display_name
		   RealmUser_2.realm_id));
	    return if $d eq $e;
	    $c ||= '';
	    unless ($map->{"$d$;$c"}) {
		$map->{"$d$;$c"} = $n;
		return;
	    }
	    return {
		'RealmOwner.realm_id' => $id,
		'RealmOwner.name' => $map->{"$d$;$c"},
		'RealmOwner.display_name' => $d,
		'RealmUser.realm_id' => $c,
		'RealmOwner_2.name' => $n,
	    };
	},
    );
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{class_name} = $row->{'RealmUser.realm_id'}
	? $self->get_request->get('Model.ClassList')
	    ->find_row_by_id($row->{'RealmUser.realm_id'})->get('class_name')
	: '';
    return 1;
}

1;
