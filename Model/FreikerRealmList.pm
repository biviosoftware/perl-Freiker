# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerRealmList;
use strict;
use Bivio::Base 'Model.RealmUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FREIKER) = __PACKAGE__->use('Auth.Role')->FREIKER;

sub internal_get_roles {
    return [$_FREIKER];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        auth_id => 'RealmUser.user_id',
	other => [
	    [qw(RealmUser.realm_id RealmOwner_2.realm_id)],
	    'RealmOwner_2.realm_type',
	],
	order_by => [
	    'RealmOwner_2.realm_type',
	],
    });
}

1;
