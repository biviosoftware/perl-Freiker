# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
sub create_prize_coupon {
    my($prize_name, $child_id) = @_;
    req()->with_realm(
	Freiker::Test->SPONSOR_NAME,
	sub {
	    $child_id ||= realm_id('child'),
		my($prize) = model(Prize => {name => $prize_name});
	    model('PrizeCoupon')->create({
		realm_id => realm_id(Freiker::Test->DISTRIBUTOR_NAME),
		user_id => $child_id,
		prize_id => $prize->get('prize_id'),
		ride_count => $prize->get('ride_count'),
	    });
	    return;
	},
    );
    return;
}

1;

