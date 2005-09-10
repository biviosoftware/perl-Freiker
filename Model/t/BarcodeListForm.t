# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Freiker::Test;
my($req) = Freiker::Test->set_up_wheel_school;
Freiker::Test->set_up_barcodes(2, $req);
my($bcl) = Bivio::Biz::Model->new($req, 'BarcodeList')->load_all;
$bcl->get_result_set_size == 2 || die('wrong count for BarcodeList');
my($cid) = Bivio::Biz::Model->new($req, 'ClassList')
    ->load_all->set_cursor_or_die(0)->get('Class.class_id');
Bivio::Test->new('Freiker::Model::BarcodeListForm')->unit([
    [$req] => [
	execute => [
	    [$req, {
		'Class.class_id_0' => $bcl->EMPTY_KEY_VALUE,
		'RealmOwner.display_name_0' => 'jonny',
		'Class.class_id_1' => $cid,
		'RealmOwner.display_name_0' => undef,
	    }] => undef,
	],
    ],
]);
