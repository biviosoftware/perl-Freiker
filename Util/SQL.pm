# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use base 'Bivio::Util::SQL';
use Bivio::Test::Language::HTTP;
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

# su - postgres -c 'createuser --no-createdb --no-adduser --pwprompt fruser; createdb --owner fruser fr'

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
    $self->create_test_user(Freiker::Test->FREIKOMETER);
    $self->new_other('RealmAdmin')->join_user('FREIKOMETER');
    $req->set_realm($club_id);
    my($epc) = Bivio::Type->get_instance('EPC');
    my($other_epc) = $epc->new(
	Freiker::Test->ZIP, Freiker::Test->FREIKER_CODE(1))
	->as_string;
    $epc = $epc->new(Freiker::Test->ZIP, Freiker::Test->FREIKER_CODE)
	->as_string;
    Bivio::Biz::Model->new($req, 'FreikerCode')
	    ->import_csv("$epc\n$other_epc\n");
    my($r) = Bivio::Biz::Model->new($req, 'Ride');
    $r->import_csv(
	$r->CSV_HEADER . "\n$epc," . $_DT->local_now_as_file_name . "\n");
    $self->model(UserRegisterForm => {
	'RealmOwner.display_name' => Freiker::Test->PARENT,
	'Address.zip' => Freiker::Test->ZIP,
	'RealmOwner.name' => Freiker::Test->PARENT,
	'RealmOwner.password' => $self->TEST_PASSWORD,
	'confirm_password' => $self->TEST_PASSWORD,
	'Email.email' => $self->format_test_email(Freiker::Test->PARENT),
	password_ok => 1,
    });
    my($parent) = $req->get_nested('Model.User', 'user_id');
    foreach my $n (0, 1) {
	$req->set_realm($parent);
	$self->model(FreikerForm => {
	    'User.first_name' => my $name = Freiker::Test->CHILD($n),
	    'Club.club_id' => $club_id,
	    'FreikerCode.freiker_code' => Freiker::Test->FREIKER_CODE($n),
	    'User.gender' => $self->use('Type.Gender')->FEMALE,
	    'birth_year' => 1999,
	});
	$req->set_realm($req->get_nested(qw(Model.User user_id)));
	$req->get_nested(qw(auth_realm owner))->update({name => $name});
    }
    return;
}

sub internal_upgrade_db {
    my($self) = @_;
    $self->internal_upgrade_db_ride;
    return;
}

sub internal_upgrade_db_ride {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE ride_t
    ADD COLUMN is_manual_entry NUMERIC(1)
/
ALTER TABLE ride_t
    ADD COLUMN ride_time DATE
/
UPDATE ride_t
    SET is_manual_entry = 0, ride_time = TO_DATE('2378497 79199', 'J SSSS')
/
ALTER TABLE ride_t
    ALTER COLUMN is_manual_entry SET NOT NULL
/
ALTER TABLE ride_t
    ALTER COLUMN ride_time SET NOT NULL
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t8
  CHECK (is_manual_entry BETWEEN 0 AND 1)
/
EOF
    return;
}

1;
