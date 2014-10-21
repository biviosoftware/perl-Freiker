# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::GroupAdmin;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub user_bulletin_list_csv {
    return shift->internal_body(
	CSV(
	    'GroupUserBulletinList',
	    [qw(
	        Email.email
		User.first_name
		User.middle_name
		User.last_name
	    )],
            {
	        want_iterate_start => 1,
	    },
	),
    );
}

1;
