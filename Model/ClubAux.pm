# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubAux;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = Bivio::Type->get_instance('RealmName');

sub create_realm {
    my($self, $club_aux, $admin_id, $display_name, $address) = @_;
    my($c, $ro) = $self->new_other('Club')->create_realm({},
	{
	    name => $_RN->from_display_name_and_zip($display_name, $address->{zip}),
	    display_name => $display_name,
	},
	$admin_id,
    );
    $self->get_request->set_realm($ro);
    $self->new_other('Address')->create({
	%$address,
	realm_id => $c->get('club_id'),
    });
    return $self;
}

sub internal_initialize {
    my($self) = @_;
    return {
        version => 1,
	table_name => 'club_aux_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    club_size => ['ClubSize', 'NOT_NULL'],
#TODO: Use Website PM
	    website => ['HTTPURI', 'NOT_NULL'],
        },
    };
}

1;
