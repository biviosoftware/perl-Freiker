# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use Bivio::Base 'Model.YearBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_U) = b_use('Model.User');
my($_SA) = b_use('Type.StringArray');
my($_D) = b_use('Type.Date');
my($_FREIKER) = b_use('Auth.Role')->FREIKER->as_sql_param;
my($_USER) = b_use('Auth.Role')->USER->as_sql_param;
my($_DATE) = $_D->to_sql_value('?');
my($_LOCATION) = b_use('Model.Address')->DEFAULT_LOCATION->as_sql_param;
my($_PARENT_EMAIL) = <<"EOF";
(SELECT e.email
    FROM realm_owner_t ro, realm_user_t ru, email_t e
    WHERE ro.realm_type = @{[b_use('Auth.RealmType')->USER->as_sql_param]}
    AND ru.role = $_FREIKER
    AND e.location = $_LOCATION
    AND ru.realm_id = ro.realm_id
    AND realm_user_t.user_id = ru.user_id
    AND e.realm_id = ro.realm_id
)
EOF
my($_RIDE_COUNT) = "(SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id AND ride_date BETWEEN $_DATE AND $_DATE)";
my($_K) = b_use('Type.Kilometers');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_FLQF) = b_use('Model.FreikerListQueryForm');

sub NOT_FOUND_IF_EMPTY {
    return 1;
}

sub PRIZE_SELECT_LIST {
    return 'PrizeSelectList';
}

#TODO: refactor to share code with FreikerForm
sub in_miles {
    my($self) = @_;
    return ($self->[$_IDI] ||= {in_miles => _in_miles($self)})->{in_miles};
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
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	want_page_count => 0,
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id User.user_id FreikerInfo.user_id Address.realm_id)],
	],
	order_by => [
	    'User.last_name_sort',
	    'User.first_name_sort',
	    'User.middle_name_sort',
 	    {
 		name => 'parent_display_name_sort',
 		type => 'DisplayName',
 		constraint => 'NONE',
 		select_value => "(SELECT COALESCE(u.last_name_sort,'') || '!!!' || COALESCE(u.first_name_sort,'') || '!!!' || COALESCE(u.middle_name_sort,'')
                     FROM realm_user_t ru, user_t u
                     WHERE ru.role = $_FREIKER
                     AND ru.realm_id = u.user_id
                     AND realm_user_t.user_id = ru.user_id
                 ) AS parent_display_name_sort",
 		sort_order => 0,
 	    },
	    {
		name => 'ride_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{$_RIDE_COUNT AS ride_count},
		sort_order => 0,
	    },
	    {
		name => 'prize_debit',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{COALESCE((SELECT SUM(ride_count) FROM prize_coupon_t WHERE prize_coupon_t.user_id = realm_user_t.user_id AND prize_coupon_t.creation_date_time BETWEEN $_DATE AND ($_DATE + interval '60 days')), 0) AS prize_debit},
		sort_order => 0,
	    },
	    {
		name => 'prize_credit',
		type => 'Integer',
		constraint => 'NOT_NULL',
		select_value => qq{((SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id AND ride_t.ride_date BETWEEN $_DATE AND $_DATE) - COALESCE((SELECT SUM(ride_count) FROM prize_coupon_t WHERE prize_coupon_t.user_id = realm_user_t.user_id AND prize_coupon_t.creation_date_time BETWEEN $_DATE AND ($_DATE + interval '60 days')), 0)) AS prize_credit},
		sort_order => 0,
	    },
	    {
		name => 'parent_email',
		type => 'Email',
		constraint => 'NONE',
		select_value => "$_PARENT_EMAIL AS parent_email",
		sort_order => 0,
	    },
	    'FreikerInfo.distance_kilometers',
	    'Address.zip',
	    'User.first_name',
	    'User.gender',
	    'User.birth_date',

	],
	other_query_keys => [qw(
	    fr_trips
	    fr_year
	    fr_registered
	    fr_begin
	    fr_end
	)],
	other => [
	    'Address.street1',
	    'Address.street2',
	    'Address.city',
	    'Address.state',
 	    map(+{
 		name => "parent_${_}_name",
 		type => 'Name',
 		constraint => 'NONE',
 		select_value => "(SELECT COALESCE(u.${_}_name,'')
                     FROM realm_user_t ru, user_t u
                     WHERE ru.role = $_FREIKER
                     AND ru.realm_id = u.user_id
                     AND realm_user_t.user_id = ru.user_id
                ) AS parent_${_}_name",
 	    }, qw(last first middle)),
 	    {
 		name => "parent_display_name",
 		type => 'DisplayName',
 		constraint => 'NONE',
 		select_value => "(SELECT COALESCE(u.last_name,'') || '!!!' || COALESCE(u.first_name,'') || '!!!' || COALESCE(u.middle_name,'')
                     FROM realm_user_t ru, user_t u
                     WHERE ru.role = $_FREIKER
                     AND ru.realm_id = u.user_id
                     AND realm_user_t.user_id = ru.user_id
                 ) AS parent_display_name",
 	    },
	    {
		name => "parent_zip",
		type => 'Name',
		constraint => 'NONE',
		select_value => "(SELECT a.zip
                     FROM realm_user_t ru, address_t a, realm_owner_t ro
                     WHERE ru.role = $_FREIKER
                     AND ru.realm_id = a.realm_id
                     AND a.location = $_LOCATION
                     AND realm_user_t.user_id = ru.user_id
                     AND ru.realm_id = ro.realm_id
                     AND ro.realm_type = $_USER
                 ) AS parent_zip",
	    },
 	    {
 		name => 'school_class_display_name',
 		type => 'DisplayName',
 		constraint => 'NONE',
 		select_value => "(select ro.display_name
                     FROM realm_user_t ru, school_class_t sc, realm_owner_t ro, school_year_t sy
                     WHERE ru.role = $_FREIKER
                     AND realm_user_t.user_id = ru.user_id
                     AND ru.realm_id = sc.school_class_id
                     AND sc.school_class_id = ro.realm_id
                     AND sc.school_year_id = sy.school_year_id
                     AND sy.start_date = $_DATE
                 ) AS school_class_display_name",
 	    },
 	    {
 		name => 'school_grade',
 		type => 'SchoolGrade',
 		constraint => 'NONE',
 		select_value => "(select school_grade
                     FROM realm_user_t ru, school_class_t sc, school_year_t sy
                     WHERE ru.role = $_FREIKER
                     AND realm_user_t.user_id = ru.user_id
                     AND ru.realm_id = sc.school_class_id
                     AND sc.school_year_id = sy.school_year_id
                     AND sy.start_date = $_DATE
                 ) AS school_grade",
 	    },
	    {
		name => 'RealmUser.role',
		in_select => 0,
	    },
	    $self->field_decl(
		[
		    [qw(can_select_prize Boolean)],
		    [qw(prize_select_list Model.PrizeSelectList)],
		    [qw(freiker_codes StringArray)],
		    [qw(birth_year Year NONE)],
		    [qw(miles Miles)],
		    [qw(display_name DisplayName)],
		],
		'NOT_NULL',
	    ),
	    {
		name => 'Address.location',
		in_select => 0,
	    },
	],
	group_by => [qw(
	    RealmUser.user_id
	    RealmOwner.display_name
	    RealmUser.realm_id
	    Address.country
	    RealmOwner.display_name
	    Address.street1
	    Address.street2
	    Address.city
	    Address.state
            Address.zip
            User.first_name
            User.first_name_sort
            User.middle_name
            User.middle_name_sort
            User.last_name
            User.last_name_sort
            User.gender
            User.birth_date
	    FreikerInfo.distance_kilometers
        )],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{freiker_codes} = $self->internal_freiker_codes($row);
    $row->{can_select_prize} = $self->internal_can_select_prize($row);
    $row->{parent_display_name} = $_U->concat_last_first_middle(
 	split(/!!!/, $row->{parent_display_name} || ''),
    );
    $row->{parent_display_name_sort} = $_U->concat_last_first_middle(
 	split(/!!!/, $row->{parent_display_name_sort} || ''),
    );
    $row->{birth_year} = $row->{'User.birth_date'}
 	&& $_D->get_parts($row->{'User.birth_date'}, 'year');
    $row->{miles} = $row->{'FreikerInfo.distance_kilometers'}
	&& $_K->to_miles($row->{'FreikerInfo.distance_kilometers'});
    $row->{'User.gender'} = undef
       if $row->{'User.gender'} && $row->{'User.gender'}->eq_unknown;
    $row->{display_name} = $_U->concat_last_first_middle(
	@$row{qw(User.last_name User.first_name User.middle_name)},
    );
    return 1;
}

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($x) = {
	date => $_D->get_max,
	begin_date => $_D->get_min,
    };
    if (my $fr_begin = _get_from_query($self, 'fr_begin')) {
	$x->{begin_date} = $fr_begin;
    }
    if (my $fr_end = _get_from_query($self, 'fr_end')) {
	$x->{date} = $fr_end;
    }
    foreach my $which (sort(keys(%$x))) {
	next
	    unless my $v = $query->unsafe_get($which);
	$x->{$which} = ($_D->from_literal($v))[0]
	    || $x->{$which};
    }
    my($sy_date) = $self->new_other('SchoolYear')
	->this_year_start_date;
    unshift(
	@$params,
	map(@$x{qw(begin_date date)}, 1..4),
	$sy_date,
	$sy_date,
	$self->req('auth_id'),
    );
    my($where) = shift->SUPER::internal_pre_load(@_);
    return join(
	' AND ',
	"address_t.location = $_LOCATION",
        'realm_user_t.realm_id = ?',
	"realm_user_t.role = $_FREIKER",
	_get_from_query($self, 'fr_registered') ? "$_PARENT_EMAIL IS NOT NULL"
	    : (),
	sub {
	    return
		unless _get_from_query($self, 'fr_trips');
	    push(@$params, @$x{qw(begin_date date)});
	    return "$_RIDE_COUNT > 0";
	}->(),
	$where ? $where : (),
    );
}

sub _get_from_query {
    return $_FLQF->get_value_fr(@_);
}

sub _in_miles {
    my($self) = @_;
    return 1
	unless $self->ureq('auth_user');
    return _is_us(
	$self->new_other('Address')->load_for_auth_user
	->get('country'),
    );
}

#TODO: Copied from FreikerForm
sub _is_us {
    return (shift || '') eq 'US' ? 1 : 0;
}

1;
