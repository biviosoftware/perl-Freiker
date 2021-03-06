# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerList;
use strict;
use Bivio::Base 'Model.YearBaseList';

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
my($_RIDE_COUNT) = "(SELECT COUNT(*) FROM ride_t WHERE ride_t.user_id = realm_user_t.user_id AND ride_date BETWEEN $_DATE AND $_DATE AND CAST(ride_type as TEXT) LIKE ?)";
my($_HAS_GRADUATED) = b_use('Type.RowTagKey')->HAS_GRADUATED->as_sql_param;
my($_K) = b_use('Type.Kilometers');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_FLQF) = b_use('Model.FreikerListQueryForm');
my($_RTK) = b_use('Type.RowTagKey');

sub CALORIES_PER_MILE {
    return 42.9;
}

sub CO2_POUNDS_PER_MILE {
    return 1.5 * 1.1;
}

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
	],
	other_query_keys => [qw(
	    fr_trips
	    fr_year
	    fr_registered
	    fr_current
	    fr_begin
	    fr_end
	    fr_type
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
		name => 'class_display_name',
		type => 'String',
		constraint => 'NONE',
	    },
 	    {
 		name => 'school_class_id',
 		type => 'DisplayName',
 		constraint => 'NONE',
 		select_value => "(select sc.school_class_id
                     FROM realm_user_t ru, school_class_t sc, realm_owner_t ro, school_year_t sy
                     WHERE ru.role = $_FREIKER
                     AND realm_user_t.user_id = ru.user_id
                     AND ru.realm_id = sc.school_class_id
                     AND sc.school_class_id = ro.realm_id
                     AND sc.school_year_id = sy.school_year_id
                     AND sy.start_date = $_DATE
                 ) AS school_class_id",
 	    },
	    {
		name => 'RealmUser.role',
		in_select => 0,
	    },
	    {
		name => 'current_miles',
		type => 'Miles',
		constraint => 'NONE',
	    },
	    {
		name => 'current_kilometers',
		type => 'Kilometers',
		constraint => 'NONE',
	    },
	    {
		name => 'calories',
		type => 'Integer',
		constraint => 'NONE',
	    },
	    {
		name => 'co2_saved',
		type => 'Integer',
		constraint => 'NONE',
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
	    {
		name => 'has_graduated',
		type => 'BooleanFalseDefault',
		constraint => 'NONE',
		select_value => "(SELECT rt.value
                     FROM realm_user_t ru, row_tag_t rt
                     WHERE ru.role = $_FREIKER
                     AND realm_user_t.realm_id = ru.realm_id
                     AND realm_user_t.user_id = ru.user_id
                     AND ru.user_id = rt.primary_id
                     AND rt.key = $_HAS_GRADUATED
                ) AS has_graduated",
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
    $row->{current_miles} = $row->{miles} && $row->{ride_count}
	&& 2 * $row->{miles} * $row->{ride_count};
    $row->{current_kilometers} = $row->{'FreikerInfo.distance_kilometers'}
	&& $row->{ride_count}
	&& 2 * $row->{'FreikerInfo.distance_kilometers'} * $row->{ride_count};
    $row->{'User.gender'} = undef
       if $row->{'User.gender'} && $row->{'User.gender'}->eq_unknown;
    $row->{display_name} = $_U->concat_last_first_middle(
	@$row{qw(User.last_name User.first_name User.middle_name)},
    );
    $row->{class_display_name} = $row->{'school_grade'}
	&& $row->{'school_class_display_name'}
	&& join(' ', ($row->{school_grade}->get_short_desc,
		      $row->{school_class_display_name}));
    $row->{calories} = $row->{current_miles}
	&& $row->{current_miles} * $self->CALORIES_PER_MILE;
    $row->{co2_saved} = $row->{current_miles}
	&& $row->{current_miles} * $self->CO2_POUNDS_PER_MILE;
    return 1;
}

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($x) = {
	date => $_D->get_max,
	begin_date => $_D->get_min,
	type => '%',
    };
    if (my $fr_begin = _get_from_query($self, 'fr_begin')) {
	$x->{begin_date} = $fr_begin;
    }
    if (my $fr_end = _get_from_query($self, 'fr_end')) {
	$x->{date} = $fr_end;
    }
    if (my $fr_type = _get_from_query($self, 'fr_type')) {
	$x->{type} = $fr_type->as_sql_param;
    }
    foreach my $which (sort(keys(%$x))) {
	next
	    unless my $v = $query->unsafe_get($which);
	$x->{$which} = ($_D->from_literal($v))[0]
	    || $x->{$which};
    }
    my($sy_date) = $self->new_other('SchoolYear')->set_ephemeral
	->this_year_start_date;
    my($where) = shift->SUPER::internal_pre_load(@_);
    push(
	@$params,
	map(@$x{qw(begin_date date)}, 1..4),
	$x->{type},
	$sy_date,
	$sy_date,
	$sy_date,
	$self->req('auth_id'),
    );
    return join(
	' AND ',
	$where ? $where : (),
	"address_t.location = $_LOCATION",
        'realm_user_t.realm_id = ?',
	"realm_user_t.role = $_FREIKER",
	_get_from_query($self, 'fr_registered') ? "$_PARENT_EMAIL IS NOT NULL"
	    : (),
	sub {
	    return
		unless _get_from_query($self, 'fr_trips');
	    push(@$params, @$x{qw(begin_date date)});
	    push(@$params, $x->{type});
	    return "$_RIDE_COUNT > 0";
	}->(),
	sub {
	    return
		unless _get_from_query($self, 'fr_current');
	    my($not_in) = 'realm_user_t.user_id NOT IN (';
	    my($found) = 0;
	    map({
		$not_in .= '?,';
		push(@$params, $_);
		$found = 1;
	    } @{$self->new_other('RowTag')->set_ephemeral->map_iterate(
		'primary_id',
		'iterate_start', {
		    key => $_RTK->HAS_GRADUATED,
		})}
	    );
	    return
		unless $found;
	    chop($not_in);
	    $not_in .= ')';
	    return $not_in;
	}->(),
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
