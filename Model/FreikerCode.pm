# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCode;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EPC) = Bivio::Type->get_instance('EPC');

sub REALM_ID_FIELD {
    return 'club_id';
}

sub create_from_epc_and_code {
    my($self, $epc, $code) = @_;
    return $self->create({
	epc => $epc,
	freiker_code => $code,
	user_id => $self->new_other('User')->create_freiker($code),
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'freiker_code_t',
	columns => {
	    freiker_code => ['FreikerCode', 'PRIMARY_KEY'],
	    epc => ['EPC', 'NOT_NULL'],
            user_id => ['User.user_id', 'NOT_NULL'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
        },
    });
}

sub unsafe_get_realm_ids {
    my($self, $freiker_code) = @_;
    return !$self->unauth_load({freiker_code => $freiker_code}) ? () : (
	$self->get(qw(user_id club_id)),
	$self->get_request->with_realm($self->get('user_id'), sub {
	    Bivio::Die->eval(sub {
	        $self->new_other('RealmUser')->get_any_online_admin;
	    });
	}),
    );
}

1;
