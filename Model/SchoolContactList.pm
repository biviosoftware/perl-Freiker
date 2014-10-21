# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolContactList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [[qw(SchoolContact.club_id RealmOwner.realm_id)]],
	order_by => [qw(
	    RealmOwner.display_name
	)],
	other => [qw(
	    SchoolContact.email
	    SchoolContact.display_name
	),
	    {
		name => 'email_display_name',
		type => 'String',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{email_display_name}
	= $self->get('RealmOwner.display_name') . ' - '
	    . $self->get('SchoolContact.display_name')
	    . ' <' . $self->get('SchoolContact.email') . '>';
    return 1;
}

1;
