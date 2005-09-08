# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Freiker::Test;
my($req) = Freiker::Test->set_up_wheel_school;
my($codes) = Freiker::Test->set_up_barcodes(3, $req);
Bivio::Test::ListModel->unit('BarcodeList', [
    load_all => [
	[] => [map({
	    {'RealmOwner.name' => $_, 'RealmUser_2.realm_id' => undef};
	} @$codes)],
    ],
]);
