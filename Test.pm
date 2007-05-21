# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Test;
use strict;
use base 'Bivio::Test';
use Bivio::Biz::Action;
use Bivio::Test::ListModel;
use Bivio::Test::Request;
use Bivio::Util::RealmAdmin;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = Bivio::Type->get_instance('RealmName');

sub ADM {
    return 'adm';
}

sub CHILD_1 {
    return 'child_1';
}

sub CHILD {
    return 'child' . ($_[1] || 0);
}

sub DISTRIBUTOR {
    return 'distributor';
}

sub DISTRIBUTOR_EMP {
    return 'distributor_emp';
}

sub DISTRIBUTOR_NAME {
    my($proto) = @_;
    return $_RN->from_display_name_and_zip($proto->DISTRIBUTOR, $proto->ZIP);
}

sub FREIKER_CODE {
    return '1234' + ($_[1] || 0);
}

sub FREIKOMETER {
    return 'freikometer';
}

sub PARENT {
    return 'parent';
}

sub SCHOOL {
    return 'bunit Elementary';
}

sub SCHOOL_NAME {
    #loosely coupled with UserRegisterForm
    return 'bunit' . shift->ZIP;
}

sub SPONSOR {
    return 'sponsor';
}

sub SPONSOR_EMP {
    return 'sponsor_emp';
}

sub SPONSOR_NAME {
    my($proto) = @_;
    return $_RN->from_display_name_and_zip($proto->SPONSOR, $proto->ZIP);
}

sub WEBSITE {
    return 'http://www.bivio.biz';
}

sub WHEEL {
    return 'wheel';
}

sub ZIP {
    return '123456789';
}

1;
