# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmPrizeCouponList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = __PACKAGE__->use('Type.StringArray');
my($_FREIKER_INT) = b_use('Auth.Role')->FREIKER->as_sql_param;
my($_USER_INT) = b_use('Auth.RealmType')->USER->as_sql_param;

sub PAGE_SIZE {
    return 500;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id PrizeCoupon.user_id)],
	    'PrizeCoupon.realm_id',
	    'PrizeCoupon.coupon_code',
	],
	order_by => [
	    'PrizeCoupon.creation_date_time',
	    'Prize.name',
	    'RealmOwner.display_name',
	    {
		name => 'family_display_name',
		type => 'DisplayName',
		constraint => 'NONE',
		select_value => "(SELECT display_name
                    FROM realm_user_t family_ru, realm_owner_t family_ro
                    WHERE family_ru.role = $_FREIKER_INT
                    AND family_ro.realm_type = $_USER_INT
                    AND family_ru.user_id = realm_user_t.user_id
                    AND family_ru.realm_id = family_ro.realm_id
                ) as family_display_name",
	    },
	],
	other => [
	    ['RealmUser.role', ['FREIKER']],
	    [qw(PrizeCoupon.prize_id Prize.prize_id)],
	    {
		name => 'freiker_codes',
		type => 'StringArray',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{freiker_codes} = $_SA->new($self->new_other('UserFreikerCodeList')
	->get_codes($row->{'RealmUser.user_id'}));
    return 1;
}

1;
