# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerBaseList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = __PACKAGE__->use('Type.StringArray');
my($_D) = b_use('Type.Date');

sub internal_initialize {
    my($self) = @_;
    my($d) = $_D->to_sql_value('?');
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	want_page_count => 0,
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
	],
	order_by => [
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
                ) AS parent_display_name",
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
                ) AS parent_email",
		sort_order => 0,
	    },
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{(SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id) AS ride_count},
		sort_order => 0,
	    },
	],
	other => [
	    [{
		name => 'RealmUser.role',
		in_select => 0,
	    }, ['FREIKER']],
	    {
		name => 'freiker_codes',
		type => 'StringArray',
		constraint => 'NOT_NULL',
	    },
	],
	auth_id => 'RealmUser.realm_id',
	group_by => [qw(RealmUser.user_id RealmOwner.display_name RealmUser.realm_id)],
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

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($x) = {
	date => 'get_max',
	begin_date => 'get_min',
    };
    foreach my $which (sort(keys(%$x))) {
	$x->{$which} = (sub {
	    my($v, $method) = @_;
	    return $v || $_D->$method();
	})->($query->unsafe_get($which), $x->{$which});
    }
#    unshift(@$params, @$x{qw(begin_date date)});
    return shift->SUPER::internal_pre_load(@_);
}

1;
