# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$

use strict;

sub create_prize_coupon {
    my($prize_name, $child_id) = @_;
    $child_id ||= model(RealmOwner => {name => 'child0'})->get('realm_id');
    my($prize) = model(Prize => {name => $prize_name});
    model('PrizeCoupon')->create({
        realm_id => model('RealmOwner' => {
            name => class('Freiker::Test')->DISTRIBUTOR_NAME,
        })->get('realm_id'),
        user_id => $child_id,
        prize_id => $prize->get('prize_id'),
        ride_count => $prize->get('ride_count'),
    });
}

1;

