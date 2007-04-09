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
req()->set_realm('parent');
$child_id = model(RealmOwner => {
    name => class('Freiker::Test')->CHILD(1),
})->get('realm_id');
my($today) = do('./SetupRides.PL');
req()->set_realm_and_user(qw(parent parent));
my($school_id) = model(RealmOwner => {
    name => Freiker::Test->SCHOOL_NAME,
})->get('realm_id');
($today, $child_id, $school_id);
