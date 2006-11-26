# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
my($today) = class('Type.Date')->now;
my($yesterday) = class('Type.Date')->add_days($today, -1);
foreach my $n (0, 1) {
    req()->set_user(class('Freiker::Test')->CHILD($n));
    model('Ride')->delete_all({
	realm_id => req('auth_user_id'),
    });
    foreach my $d ($yesterday, $n ? () : $today) {
	model('Ride')->create({
	    realm_id => req('auth_user_id'),
	    ride_date => $d,
	    freiker_code => class('Freiker::Test')->FREIKER_CODE($n),
	});
    }
}
$today;
