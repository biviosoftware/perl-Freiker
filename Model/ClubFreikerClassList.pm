# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubFreikerClassList;
use strict;
use Bivio::Base 'Model.ClubFreikerList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
    my($self, $model, $this) = @_;
    $self ||= $model;
    $this ||= $self->parse_query_from_request->get('parent_id');
    my($ro) = $self->new_other('RealmOwner');
    $ro->unauth_load({
	realm_id => $this,
    });
    my($sc) = $self->new_other('SchoolClass')->load({
	school_class_id => $this,
    });
    return join(' ',
        ($sc->get('school_grade')->get_short_desc, $ro->get('display_name')));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
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
