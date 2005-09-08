# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Freiker::Test;
my($req) = Freiker::Test->set_up_wheel_school;
Bivio::Test::ListModel->unit('ClassList', [
    load_all => [
	[] => [{
	    class_name => '1st Mr. Erste Klasse',
	}],
    ],
]);
