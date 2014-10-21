# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::TestUnit::Unit;
use strict;
use Bivio::Base 'TestUnit';

my($_FC) = b_use('Type.FreikerCode');

sub AUTOLOAD {
    $Bivio::Test::Unit::Unit::AUTOLOAD = $AUTOLOAD;
    return Bivio::Test::Unit::Unit::AUTOLOAD(@_);
}

sub builtin_realm_id {
    my($proto, $code_name_or_email) = @_;
    return shift->SUPER::builtin_realm_id(@_)
	unless ($_FC->from_literal($code_name_or_email))[0];
    my($fc) = $proto->builtin_model('FreikerCode');
    Bivio::Die->die($code_name_or_email, ': not found')
        unless $fc->unauth_load({freiker_code => $code_name_or_email});
    return $fc->get('user_id');
}

1;
