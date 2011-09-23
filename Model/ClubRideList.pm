# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubRideList;
use strict;
use Bivio::Base 'Model.AdmRideList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SCHOOL_CLASS) = b_use('Auth.RealmType')->SCHOOL_CLASS->as_sql_param;

sub AUTH_ID {
    return 'Ride.club_id';
}

sub OTHER_COLUMNS {
    return (
	{
	    name => 'class_realm_id',
	    type => 'PrimaryId',
	    constraint => 'NONE',
	    select_value => "(SELECT ro.realm_id
                FROM realm_user_t ru, realm_owner_t ro
                WHERE ru.user_id = ride_t.user_id
                AND ro.realm_id = ru.realm_id
                AND ro.realm_type = $_SCHOOL_CLASS
            ) AS class_realm_id",
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
    if ($row->{class_realm_id}) {
	my($ro) = $self->new_other('RealmOwner');
	$ro->unauth_load({
	    realm_id => $row->{class_realm_id}
	});
	$row->{class_display_name} =
	    join(' ',
		 $self->new_other('SchoolClass')->load({
		     school_class_id => $row->{class_realm_id}
		 })->get('school_grade')->get_short_desc,
		 $ro->get('display_name'),
	     );
    } else {
	$row->{class_display_name} = b_use('UI.Facade')->get_instance
	    ->get('Text')->get_value('ClubRideList.unassigned_class', $self->req);
    }
    return 1;
}

1;
