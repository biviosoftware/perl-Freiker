# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
my($child_id);
FormModel({
    setup_request => sub {
	my($params) = shift->get('params');
	model(FreikerRideList => {
	    parent_id => $child_id,
	    auth_id => req('auth_id'),
	});
	return;
    },
});
my($today) = do('./SetupRides.PL');
req()->set_realm_and_user(qw(parent parent));
($today, $child_id = realm_id('child1'), realm_id('bunit123456789'));
