# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerClassList;
use strict;
use Bivio::Base 'Model.ClubFreikerList';

my($_R) = b_use('Auth.Role');
my($_D) = b_use('Type.Date');
my($_DATE) = $_D->to_sql_value('?');
my($_FREIKER) = b_use('Auth.Role')->FREIKER->as_sql_param;
my($_CLASS_ID) = <<"EOF";
(select sc.school_class_id
    FROM realm_user_t ru, school_class_t sc, realm_owner_t ro, school_year_t sy
    WHERE ru.role = $_FREIKER
    AND realm_user_t.user_id = ru.user_id
    AND ru.realm_id = sc.school_class_id
    AND sc.school_class_id = ro.realm_id
    AND sc.school_year_id = sy.school_year_id
    AND sy.start_date = $_DATE
)
EOF

sub get_class_display_name {
    my($self, $model, $this, $with_year) = @_;
    $self ||= $model;
    $this ||= $self->parse_query_from_request->get('parent_id');
    my($ro) = $self->new_other('RealmOwner');
    $ro->unauth_load({
	realm_id => $this,
    });
    my($sc) = $self->new_other('SchoolClass')->load({
	school_class_id => $this,
    });
    my($sy) = $self->new_other('SchoolYear')->load({
	school_year_id => $sc->get('school_year_id'),
    });
    my(undef, undef, $y) = $_D->to_date_parts(
	$_D->from_literal($sy->get('start_date')));
    return join(' ',
		$sc->get('school_grade')->get_short_desc,
		$ro->get('display_name'),
		$with_year ? "($y)" : ());
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    $self->throw_die('MODEL_NOT_FOUND')
	unless $query->get('parent_id');
    my($sy_date) = $self->new_other('SchoolYear')->set_ephemeral
	->this_year_start_date;
    my($where) = shift->SUPER::internal_pre_load(@_);
    push(@$params, $sy_date);
    return join(
	' AND ',
	$where ? $where : (),
	"$_CLASS_ID = " . $query->get('parent_id'),
    );
}

1;
