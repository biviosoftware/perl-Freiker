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

sub ADM {
    return 'adm';
}

sub CHILD {
    return 'child';
}

sub FREIKER_CODE {
    return '1234';
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

sub WEBSITE {
    return 'http://www.bivio.biz';
}

sub WHEEL {
    return 'wheel';
}

sub ZIP {
    return '123456789';
}

sub delete_all_schools {
    my($proto) = @_;
    my($req) = Bivio::Test::Request->get_instance;
    Bivio::Biz::Model->new($req, 'RealmOwner')->map_iterate(
	sub {
	    my($m) = @_;
	    Freiker::Test->delete_school($m->get('realm_id'), $req)
		    unless $m->is_default;
	    return 1;
	},
	unauth_iterate_start =>
	    'name desc',
	{realm_type => Bivio::Auth::RealmType->SCHOOL},
    );
    return $req;
}

sub delete_freikers {
    my(undef, $req) = @_;
    foreach my $u (
	@{Bivio::Biz::Model->new($req, 'FreikerList')->map_iterate(
	    sub {shift->get('User.user_id')},
	)},
    ) {
	Bivio::Biz::Model->new($req, 'Ride')->delete_all({
	    user_id => $u,
	});
	foreach my $v (
	    @{Bivio::Biz::Model->new($req, 'RealmUser')->map_iterate(
		sub {
		    my($m) = @_;
		    return {
			map(($_ => $m->get($_)), 'realm_id', 'role', 'user_id'),
		    };
	        },
		unauth_iterate_start => 'realm_id',
		{user_id => $u}
	    )},
	) {
	    Bivio::Biz::Model->new($req, 'RealmUser')->unauth_delete($v);
	}
	Bivio::Biz::Model->new($req, 'User')
	    ->unauth_load_or_die({user_id => $u})
	    ->cascade_delete;
    }
    return;
}

sub delete_school {
    my($proto, $school_id, $req) = @_;
    $req->set_realm($school_id);
    $proto->delete_freikers($req);
    foreach my $u (
	@{Bivio::Biz::Model->new($req, 'FreikerList')->map_iterate(
	    sub {shift->get('User.user_id')},
	)},
    ) {
	Bivio::Biz::Model->new($req, 'RealmUser')->delete_all({
	    user_id => $u,
	    role => Bivio::Auth::Role->FREIKER,
	});
	Bivio::Biz::Model->new($req, 'RealmUser')->delete_all({
	    user_id => $u,
	    role => Bivio::Auth::Role->STUDENT,
	});
	Bivio::Biz::Model->new($req, 'Ride')->delete_all({
	    user_id => $u,
	});
	Bivio::Biz::Model->new($req, 'User')
	    ->unauth_load_or_die({user_id => $u})
	    ->cascade_delete;
    }
    $req->set_realm($school_id);
    foreach my $r (
	@{Bivio::Biz::Model->new($req, 'Class')->map_iterate(
	    sub {shift->get('class_id')},
	    unauth_iterate_start => 'class_id', {school_id => $school_id},
	)},
	$school_id,
    ) {
	$req->set_realm($r);
	Bivio::Util::RealmAdmin->delete_with_users;
    }
    return;
}

sub set_up_barcodes {
    my($proto, $count, $req) = @_;
    my($sid) = $req->get('auth_id');
    $proto->delete_freikers($req);
    $req->set_realm($sid);
    $req->set_user($proto->WHEEL);
    my($code) = $req->get_nested(qw(auth_realm owner name));
    my($codes) = [map(($code++, $code)[1], 1 .. $count)];
    Bivio::Biz::Model->get_instance('BarcodeUploadForm')->execute(
	$req, {
	    barcode_file => {
		content => \(join("\n", @$codes)),
		filename => Bivio::Type::Date->local_now_as_file_name,
	    },
	},
    );
    return $codes;
}

sub set_up_wheel_school {
    my($proto) = @_;
    my($req) = Bivio::Test::Request->get_instance;
    $req->set_user($proto->WHEEL);
    $req->set_realm(
	Bivio::Biz::Model->new($req, 'RealmOwner')
	    ->unauth_load_or_die({display_name => $proto->SCHOOL}));
    return $req;
}

1;
