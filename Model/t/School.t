# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Freiker::Test;
use Bivio::Util::RealmAdmin;
my($req) = Freiker::Test->delete_all_schools;
Bivio::Test->new('Freiker::Model::School')->unit([
    [$req] => [
	{
	    method => 'create_realm',
	    compute_return => sub {
		return [$req->get_nested(qw(auth_realm owner_name))],
	    },
	} => [
	    map(
		([$_, "http://$_.com"] => ($_ . '000')),
		'a' .. 'z', 'aa' .. 'az', 'ba',
	    ),
	],
    ]
]);

