# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmPrizeCouponList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = __PACKAGE__->use('Type.StringArray');

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
