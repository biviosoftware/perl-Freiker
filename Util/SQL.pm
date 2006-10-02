# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use base 'Bivio::Util::SQL';
use Bivio::Test::Language::HTTP;
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');

# su - postgres -c 'createuser --no-createdb --no-adduser --pwprompt fruser; createdb --owner fruser fr'

#TODO: Remove after 10/15/06
sub TEST_PASSWORD {
    return 'password';
}

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'fr']);
}

sub init_realm_role {
    my($self) = shift;
    my(@res) = $self->SUPER::init_realm_role(@_);
    my($rr) = $self->new_other('Bivio::Biz::Util::RealmRole');
    foreach my $realm (qw(general user club)) {
	$self->set_realm_and_user($realm, 'user');
	$rr->edit(ADMINISTRATOR => '+RIDE_WRITE');
	$rr->edit(FREIKOMETER => qw(+USER +RIDE_WRITE));
	# Just in case these are set
	$rr->edit(MEMBER => qw(-DATA_WRITE -ADMIN_WRITE -ADMIN_READ));
    }
    return @res;
}

sub initialize_test_data {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->create_test_user(Freiker::Test->ADM);
    $self->new_other('Bivio::Biz::Util::RealmRole')->make_super_user;
    Bivio::Biz::Model->new($req, 'ClubRegisterForm')->process({
	club_name => Freiker::Test->SCHOOL,
	'Address.zip' => Freiker::Test->ZIP,
	'RealmOwner.display_name' => Freiker::Test->WHEEL,
	'RealmOwner.name' => Freiker::Test->WHEEL,
	'RealmOwner.password' => $self->TEST_PASSWORD,
	'confirm_password' => $self->TEST_PASSWORD,
	'ClubAux.website' => Freiker::Test->WEBSITE,
	'ClubAux.club_size' => 32,
	'Email.email' => $self->format_test_email(Freiker::Test->WHEEL),
	password_ok => 1,
    });
    $req->set_realm(my $club_id = $req->get_nested('Model.Club', 'club_id'));
    my($epc) = Bivio::Type->get_instance('EPC');
    $epc = $epc->new(Freiker::Test->ZIP, Freiker::Test->FREIKER_CODE)
	->as_string;
    Bivio::Biz::Model->new($req, 'FreikerCode')->import_csv("$epc\n");
    my($r) = Bivio::Biz::Model->new($req, 'Ride');
    $r->import_csv($r->CSV_HEADER . "\n$epc," . $_D->local_today . "\n");
    Bivio::Biz::Model->new($req, 'UserRegisterForm')->process({
	'RealmOwner.display_name' => Freiker::Test->PARENT,
	'Address.zip' => Freiker::Test->ZIP,
	'RealmOwner.name' => Freiker::Test->PARENT,
	'RealmOwner.password' => $self->TEST_PASSWORD,
	'confirm_password' => $self->TEST_PASSWORD,
	'Email.email' => $self->format_test_email(Freiker::Test->PARENT),
	password_ok => 1,
    });
    $req->set_realm($req->get_nested('Model.User', 'user_id'));
    Bivio::Biz::Model->new($req, 'FreikerForm')->process({
	'User.first_name' => 'child',
	'Club.club_id' => $club_id,
	'FreikerCode.freiker_code' => Freiker::Test->FREIKER_CODE,
	'User.gender' => Bivio::Type->get_instance('Gender')->FEMALE,
	'birth_year' => 99,
    });
    return;
}

1;
