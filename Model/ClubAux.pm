# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubAux;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MAX) = Bivio::Biz::Model->get_instance('RealmOwner')->get_field_type('name')->get_width;

sub create_realm {
    my($self, $club_aux, $admin_id, $display_name, $address) = @_;
    my($n) = $display_name =~ /^(\S+)/;
    $n =~ s/\W+//g;
    my($c, $ro) = $self->new_other('Club')->create_realm({},
	{
	    name => substr($n, 0, $_MAX - length($address->{zip}))
		. $address->{zip},
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
	    website => ['HTTPURI', 'NOT_NULL'],
        },
    };
}

1;
