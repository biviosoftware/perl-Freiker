# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = __PACKAGE__->use('Type.StringArray');
my($_D) = b_use('Type.Date');
my($_FREIKER) = b_use('Auth.Role')->FREIKER->as_sql_param;

sub PRIZE_SELECT_LIST {
    return 'PrizeSelectList';
}

sub execute_load_csv {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load_all($self->parse_query_from_request->put(fr_active => 1));
    return;
}

sub internal_can_select_prize {
    my($self, $row) = @_;
    return ($row->{prize_select_list}
	= $self->new_other($self->PRIZE_SELECT_LIST)
	    ->load_for_user_and_credit(
		$row->{'RealmUser.user_id'}, $row->{prize_credit})
    )->get_result_set_size ? 1 : 0;
}

sub internal_freiker_codes {
    my($self, $row) = @_;
    return $_SA->new($self->new_other('UserFreikerCodeList')
	->get_codes($row->{'RealmUser.user_id'}));
}

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
	    'RealmOwner.display_name',
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{(SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id AND ride_date BETWEEN $d AND $d) AS ride_count},
		sort_order => 0,
	    },
	    {
		name => 'prize_debit',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{COALESCE((SELECT SUM(ride_count) FROM prize_coupon_t WHERE prize_coupon_t.user_id = realm_user_t.user_id AND prize_coupon_t.creation_date_time BETWEEN $d AND ($d + interval '60 days')), 0) AS prize_debit},
		sort_order => 0,
	    },

	    {
		name => 'prize_credit',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{((SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id AND ride_t.ride_date BETWEEN $d AND $d) - COALESCE((SELECT SUM(ride_count) FROM prize_coupon_t WHERE prize_coupon_t.user_id = realm_user_t.user_id AND prize_coupon_t.creation_date_time BETWEEN $d AND ($d + interval '60 days')), 0)) AS prize_credit},
		sort_order => 0,
	    },
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
	],
	other_query_keys => ['fr_active'],
	other => [
	    {
		name => 'can_select_prize',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'prize_select_list',
		type => 'Model.PrizeSelectList',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'RealmUser.role',
		in_select => 0,
	    },
	    {
		name => 'freiker_codes',
		type => 'StringArray',
		constraint => 'NOT_NULL',
	    },
	],
#TODO: Need to integrate internal_pre_load with auth_id.  For now, internal_prepare_statement
#      is handling auth_id.
#	auth_id => 'RealmUser.realm_id',
	group_by => [qw(RealmUser.user_id RealmOwner.display_name RealmUser.realm_id)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    return 0
	if $self->get_query->unsafe_get('fr_active')
	&& !$row->{parent_email}
	&& !$row->{ride_count};
    $row->{freiker_codes} = $self->internal_freiker_codes($row);
    $row->{can_select_prize} = $self->internal_can_select_prize($row);
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
	    return ($_D->from_literal($v))[0] || $_D->$method();
	})->($query->unsafe_get($which), $x->{$which});
    }
    if (my $d = $self->new_other('RowTag')->get_value('CLUB_END_DATE')) {
	$d = ($_D->from_literal($d))[0];
	$x->{date} = $d
	    if $d;
    }
    unshift(
	@$params,
	map(@$x{qw(begin_date date)}, 1..4),
	$self->req('auth_id'),
    );
    my($where) = shift->SUPER::internal_pre_load(@_);
    return join(
	' AND ',
        'realm_user_t.realm_id = ?',
	"realm_user_t.role = $_FREIKER",
	$where ? $where : (),
    );
}

1;
