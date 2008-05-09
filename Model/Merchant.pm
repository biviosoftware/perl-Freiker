# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Merchant;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create_realm {
    return shift->create->call_super_before(\@_, sub {
        my($self) = @_;
	$self->req->with_realm($self->get('merchant_id'), sub {
	    $self->new_other('RealmFile')->init_realm;
	    return;
	});
        return;
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'merchant_t',
	columns => {
            merchant_id => ['PrimaryId', 'PRIMARY_KEY'],
        },
    });
}

1;
