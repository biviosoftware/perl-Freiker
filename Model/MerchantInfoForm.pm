# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::MerchantInfoForm;
use strict;
use Bivio::Base 'Model.OrganizationInfoForm';

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
		(undef, $ro) = $self->new_other('Merchant')->create_realm(
		    {
			display_name => $dn,
			name => $_RN->from_display_name_and_zip(
			    $dn, $self->get('Address.zip')),
		    },
		    $req->get('auth_user_id'),
		);
		$req->with_realm($ro, sub {
		    $self->create_or_update_model_properties('Address');
		    $self->create_or_update_model_properties('Website');
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
	],
    });
}

1;
