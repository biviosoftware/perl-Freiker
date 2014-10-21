# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolClass;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';


sub create_realm {
    my($self, $values, $realm_owner) = @_;
    return $self->create($values)->SUPER::create_realm($realm_owner);
}

sub internal_create_realm_administrator_id {
    return undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'school_class_t',
        columns => {
	    school_class_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    club_id => ['Club.club_id', 'NOT_NULL'],
	    school_year_id => ['SchoolYear.school_year_id', 'NOT_NULL'],
	    school_grade => ['SchoolGrade', 'NOT_ZERO_ENUM'],
	},
    });
}

1;
