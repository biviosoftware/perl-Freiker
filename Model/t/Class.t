# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Freiker::Test;
use Bivio::Util::RealmAdmin;
my($req) = Freiker::Test->delete_all_schools();
Bivio::Test->new('Freiker::Model::Class')->unit([
    [$req, 'Class'] => [
	sub {
	    my($s) = Bivio::Biz::Model->new($req, 'School')->create_realm(
		'Class Test', 'http://class.test',
	    );
	    return 1;
	} => 1,
	create_realm => [
	    [{
		class_grade => Bivio::Type->get_instance('ClassGrade')->FIRST,
		class_size => 33,
	     }, {
		 first_name => 'Uno',
		 last_name => 'Dos',
		 gender => Bivio::Type->get_instance('Gender')->FEMALE,
	     }] => undef,
        ],
    ]
]);

