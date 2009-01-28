# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use Bivio::Base 'Model.YearBaseList';
use Freiker::Biz;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = __PACKAGE__->use('Type.StringArray');

sub PRIZE_SELECT_LIST {
    return 'PrizeSelectList';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
	],
        order_by => [
	    'RealmOwner.display_name',
	],
	other => [
	    {
		name => 'parent_display_name',
		type => 'DisplayName',
		constraint => 'NONE',
		select_value => "(SELECT ro.display_name
                    FROM realm_owner_t ro, realm_user_t ru
                    WHERE ro.realm_type = @{[b_use('Auth.RealmType')->CLUB->as_sql_param]}
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
                    WHERE ro.realm_type = @{[b_use('Auth.RealmType')->CLUB->as_sql_param]}
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
		name => 'prize_debit',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => '(SELECT SUM(ride_count) FROM prize_coupon_t WHERE prize_coupon_t.user_id = realm_user_t.user_id)',
		sort_order => 0,
	    },
	    {
		name => 'prize_credit',
		type => 'Integer',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'can_select_prize',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    ['RealmUser.role', ['FREIKER']],
	    {
		name => 'prize_select_list',
		type => 'Model.PrizeSelectList',
		constraint => 'NOT_NULL',
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
    $row->{prize_credit} = $row->{ride_count} - ($row->{prize_debit} ||= 0);
    $row->{freiker_codes} = $_SA->new($self->new_other('UserFreikerCodeList')
	->get_codes($row->{'RealmUser.user_id'}));
    $row->{can_select_prize}
	= ($row->{prize_select_list}
	    = $self->new_other($self->PRIZE_SELECT_LIST)
		->load_for_user_and_credit(
		    $row->{'RealmUser.user_id'}, $row->{prize_credit})
	)->get_result_set_size ? 1 : 0;
    return 1;
}

# sub internal_prepare_statement {
#     my($self, $stmt) = @_;
#     $stmt->from(
# 	$stmt->LEFT_JOIN_ON(qw(RealmUser parent.RealmUser), [
# 	    [qw(RealmUser.user_id parent.RealmUser.user_id)],
# 	    ['parent.RealmUser.role', ['FREIKER']],
# 	]),
# 	$stmt->LEFT_JOIN_ON(qw(parent.RealmUser parent.RealmOwner), [
# 	    [qw(parent.RealmUser.realm_id parent.RealmOwner.realm_id)],
# 	    ['parent.RealmOwner.realm_type' => ['USER']],
# 	]),
# # 	$stmt->LEFT_JOIN_ON(qw(parent.RealmOwner parent.Email), [
# # 	    [qw(parent.RealmOwner.realm_id parent.Email.realm_id)],
# # 	    ['parent.Email.location' => [b_use('Model.Email')->DEFAULT_LOCATION]],
# # 	]),
#     );
#     return shift->SUPER::internal_prepare_statement(@_);
# }

1;
