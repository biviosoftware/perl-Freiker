# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::MerchantInfoForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = Bivio::Type->get_instance('RealmName');

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($ro);
    $req->with_realm(undef, sub {
	$self->internal_catch_field_constraint_error(
	    'RealmOwner.display_name' => sub {
		my($dn) = $self->get('RealmOwner.display_name');
		(undef, $ro) = $self->new_other('Forum')->create_realm(
		    {},
		    {
			display_name => $dn,
			name => $_RN->from_display_name_and_zip(
			    $dn, $self->get('Address.zip')),
		    },
		);
		$req->with_realm($ro, sub {
		    $self->create_model_from_properties('Address');
		    return;
		});
	    },
	);
    });
    $req->set_realm($ro);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    'RealmOwner.display_name',
#TODO: Make NOT_NULL and only require street1 and zip9
	    map(+{
		name => "Address.$_",
		$_ eq 'street2' ? () : (constraint => 'NOT_NULL'),
	    }, qw(street1 street2 city state)),
	    {
		name => 'Address.zip',
		type => 'USZipCode9',
		constraint => 'NOT_NULL',
	    },
	    'Website.url',
	],
    });
}

1;
