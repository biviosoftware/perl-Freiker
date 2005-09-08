# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Test;
use strict;
$Freiker::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Test::VERSION;

=head1 NAME

Freiker::Test - common routines

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Test;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test;
@Freiker::Test::ISA = ('Bivio::Test');

=head1 DESCRIPTION

C<Freiker::Test>

=cut


=head1 CONSTANTS

=cut

=for html <a name="ADM"></a>

=head2 ADM : string

=cut

sub ADM {
    return 'adm';
}

=for html <a name="PASSWORD"></a>

=head2 PASSWORD : string

=cut

sub PASSWORD {
    return 'password';
}

=for html <a name="SCHOOL"></a>

=head2 SCHOOL : string

=cut

sub SCHOOL {
    return 'Example Elementary';
}

=for html <a name="WEBSITE"></a>

=head2 WEBSITE : string

=cut

sub WEBSITE {
    return 'http://www.example.com';
}

=for html <a name="WHEEL"></a>

=head2 WHEEL : string

=cut

sub WHEEL {
    return 'wheel';
}

=for html <a name="ZIP"></a>

=head2 ZIP : string

=cut

sub ZIP {
    return '000000000';
}

#=IMPORTS
use Bivio::Test::Request;
use Bivio::Util::RealmAdmin;
use Bivio::Test::ListModel;
use Bivio::Biz::Action;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="delete_all_schools"></a>

=head2 static delete_all_schools() : Bivio::Agent::Request

Deletes all schools and B<COMMITs>

=cut

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
    Bivio::SQL::Connection->commit;
    return $req;
}

=for html <a name="delete_freikers"></a>

=head2 static delete_freikers(Bivio::Agent::Request req) 

Deletes freikers at a school

=cut

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

=for html <a name="delete_school"></a>

=head2 static delete_school(string school_id, Bivio::Agent::Request req)

Deletes school and sets current realm to general.

=cut

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

=for html <a name="set_up_barcodes"></a>

=head2 static set_up_barcodes(int count, Bivio::Agent::Request req) : array_ref

Deletes existing barcodes and adds I<count> barcodes returning the list.

=cut

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

=for html <a name="set_up_wheel_school"></a>

=head2 static set_up_wheel_school() : Bivio::Agent::Request

Sets realm to WHEEL and and SCHOOL.

=cut

sub set_up_wheel_school {
    my($proto) = @_;
    my($req) = Bivio::Test::Request->get_instance;
    $req->set_user($proto->WHEEL);
    $req->set_realm(
	Bivio::Biz::Model->new($req, 'RealmOwner')
	    ->unauth_load_or_die({display_name => $proto->SCHOOL}));
    return $req;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
