# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRideList;
use strict;
use Bivio::Base 'Model.AdmRideList';

my($_SCHOOL_CLASS) = b_use('Auth.RealmType')->SCHOOL_CLASS->as_sql_param;
my($_CFCL) = b_use('Model.ClubFreikerClassList');
my($_D) = b_use('Type.Date');

sub AUTH_ID {
    return 'Ride.club_id';
}

sub OTHER_COLUMNS {
    return (
	{
	    name => 'class_realm_id',
	    type => 'PrimaryId',
	    constraint => 'NONE',
	},
	{
	    name => 'class_display_name',
	    type => 'String',
	    constraint => 'NONE',
	},
    );
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{class_realm_id} = $self->new_other('RealmUser')
	->unsafe_school_class_for_freiker_for_date(
	    $row->{'Ride.user_id'}, $_D->from_literal($row->{'Ride.ride_date'}));
    $row->{class_display_name} = $row->{class_realm_id}
	? $_CFCL->get_class_display_name($self, $row->{class_realm_id}, 1)
	: b_use('UI.Facade')->get_instance->get('Text')
	    ->get_value('ClubRideList.unassigned_class', $self->req);
    return 1;
}

1;
