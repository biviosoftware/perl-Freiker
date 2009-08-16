# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Test;
use strict;
use Bivio::Base 'Bivio::Test';
use Bivio::Biz::Action;
use Bivio::Test::ListModel;
use Bivio::Test::Request;
use Bivio::Util::RealmAdmin;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = Bivio::Type->get_instance('RealmName');

sub ADM {
    return 'adm';
}

sub CHILD {
    my(undef, $index, $which) = @_;
    return _string(
	child => undef, _number(0, undef, $which) * 10 + ($index || 0));
}

sub EPC {
    return sprintf('%016X%08X', 0xABCDEF, shift->FREIKER_CODE(@_));
}

sub FREIKER_CODE {
    my(undef, $index, $which) = @_;
    return _number(1234 + 1000 * _number(0, undef, $which), undef, $index);
}

sub FREIKOMETER {
    return _string(fm_freikometer => @_);
}

sub MAX_CHILD_INDEX {
    return 6;
}

sub NEED_ACCEPT_TERMS {
    return 'need_accept_terms';
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

sub WEBSITE {
    return _string('http://www.bivio.biz/', @_);
}

sub WHEEL {
    return _string('wheel', @_);
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
