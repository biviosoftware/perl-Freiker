# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Test;
use strict;
use Bivio::Base 'Bivio';
use Bivio::Biz::Action;
use Bivio::Test::ListModel;
use Bivio::Test::Request;
use Bivio::Util::RealmAdmin;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = b_use('Type.RealmName');
my($_DT) = b_use('Type.DateTime');
my($_FEMALE) = b_use('Type.Gender')->FEMALE;

sub ADM {
    return 'adm';
}

sub CA_PARENT {
    return 'ca_parent';
}

sub CA_ZIP {
    return 'M4B 1B3';
}

sub CHILD {
    my(undef, $index, $which) = @_;
    return _string(
	child => undef, _number(0, undef, $which) * 10 + ($index || 0));
}

sub DEFAULT_BIRTH_YEAR {
    return 1999;
}

sub DEFAULT_GENDER {
    return $_FEMALE;
}

sub DEFAULT_MILES {
    return '5.0';
}

sub DEFAULT_KILOMETERS {
    return '8.0';
}

sub EPC {
    return sprintf('%s%08X', '465245494B455201', shift->FREIKER_CODE(@_));
}

sub FREIKER_CODE {
    my(undef, $index, $which) = @_;
    return _number(1234 + 1000 * _number(0, undef, $which), undef, $index);
}

sub FREIKOMETER {
    return _string(fm_freikometer => @_);
}

sub MAX_CHILD_INDEX {
    return 8;
}

sub MAX_CHILD_INDEX_WITH_RIDES {
    return shift->MAX_CHILD_INDEX - 3;
}

sub CHILD_WITHOUT_RIDES {
    return shift->MAX_CHILD_INDEX_WITH_RIDES + 1;
}

sub COUNTRY {
    return 'US';
}

sub NEED_ACCEPT_TERMS {
    return 'need_accept_terms';
}

sub NEED_ACCEPT_TERMS_CHILD_INDEX {
    return shift->CHILD_WITHOUT_RIDES + 1;
}

sub PARENT {
    return _string(parent => @_);
}

sub SCHOOL {
    return shift->SCHOOL_BASE(@_) . ' Elementary' ;
}

sub SCHOOL_BASE {
    return _string('bunit', @_);
}

sub SCHOOL_GRADE {
    return b_use('Type.SchoolGrade')->from_int(_number(2, @_));
;
}

sub SCHOOL_NAME {
    my($proto, $which) = @_;
    # Loosely coupled with UserRegisterForm
    return $proto->SCHOOL_BASE($which) . $proto->ZIP($which);
}

sub SPONSOR {
    return _string('sponsor', @_);
}

sub SPONSOR_EMP {
    return _string('sponsor_emp', @_);
}

sub SPONSOR_NAME {
    my($proto, $which) = @_;
    return $_RN->from_display_name_and_zip(
	$proto->SPONSOR($which), $proto->ZIP($which));
}

sub TEACHER {
    return _string(Lehrer => @_);
}

sub TEST_NOW {
    return $_DT->from_literal_or_die('2/21/2009 8:0:0');
}

sub WEBSITE {
    return _string('http://www.bivio.biz/', @_);
}

sub WHEEL {
    return _string('wheel', @_);
}

sub ZAP {
    return _string(dz_zap => @_);
}

sub ZAP_ETHERNET {
    return 'aa:bb:cc:dd:ee:0' . _number(0 => @_);
}

sub ZIP {
    return _number(123456789, @_);
}

sub _string {
    my($base, undef, $which) = @_;
    return $base . ($which ? $which : '');
}

sub _number {
    my($base, undef, $which) = @_;
    return $base + ($which || 0);
}

1;
