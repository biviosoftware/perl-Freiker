# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerBaseList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = __PACKAGE__->use('Type.StringArray');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
	],
	other => [
	    ['RealmUser.role', ['FREIKER']],
	    {
		name => 'parent_display_name',
		type => 'DisplayName',
		constraint => 'NONE',
		select_value => "(SELECT ro.display_name
                    FROM realm_owner_t ro, realm_user_t ru
                    WHERE ro.realm_type = @{[b_use('Auth.RealmType')->USER->as_sql_param]}
                    AND ru.role = @{[b_use('Auth.Role')->FREIKER->as_sql_param]}
                    AND ru.realm_id = ro.realm_id
                    AND realm_user_t.user_id = ru.user_id
                )",
		sort_order => 0,
	    },
	    {
		name => 'parent_email',
		type => 'Email',
		constraint => 'NONE',
		select_value => "(SELECT e.email
                    FROM realm_owner_t ro, realm_user_t ru, email_t e
                    WHERE ro.realm_type = @{[b_use('Auth.RealmType')->USER->as_sql_param]}
                    AND ru.role = @{[b_use('Auth.Role')->FREIKER->as_sql_param]}
                    AND e.location = @{[b_use('Model.Email')->DEFAULT_LOCATION->as_sql_param]}
                    AND ru.realm_id = ro.realm_id
                    AND realm_user_t.user_id = ru.user_id
                    AND e.realm_id = ro.realm_id
                )",
		sort_order => 0,
	    },
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => '(SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id)',
		sort_order => 0,
	    },
	    {
		name => 'freiker_codes',
		type => 'StringArray',
		constraint => 'NOT_NULL',
	    },
	],
	auth_id => 'RealmUser.realm_id',
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{freiker_codes} = $_SA->new($self->new_other('UserFreikerCodeList')
	->get_codes($row->{'RealmUser.user_id'}));
    return 1;
}

1;
