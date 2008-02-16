# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
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

sub internal_upgrade_db_freikometer_folders {
    my($self) = @_;
    my($list) = {@{
	$self->model('RealmUser')->map_iterate(
	    sub {(shift->get('user_id') => 1)},
	    'unauth_iterate_start',
	    'realm_id',
	    {role => Bivio::Auth::Role->FREIKOMETER},
	),
    }};
    foreach my $fm (keys(%$list)) {
	$self->req->with_user($fm, sub {
	    $self->req->with_realm($fm, sub {
		$self->model('RealmFile')->init_realm->map_invoke(
		    create_folder => [
			map([{path => $self->model($_)->FOLDER}],
			    qw(FreikometerDownloadList FreikometerUploadList)),
		    ],
		);
	    }),
	});
    }
    return;
}

sub initialize_db {
    my($self) = shift;
    my(@res) = $self->SUPER::initialize_db(@_);
    $self->new_other('SiteForum')->init;
    return @res;
}

sub init_realm_role {
    my($self) = shift;
    my(@res) = $self->SUPER::init_realm_role(@_);
    my($rr) = $self->new_other('RealmRole');
    foreach my $realm (qw(general user club)) {
	$self->set_realm_and_user($realm, 'user');
	$rr->edit(ADMINISTRATOR => '+RIDE_WRITE');
	$rr->edit(FREIKOMETER => qw(+USER +RIDE_WRITE));
    }
    return @res;
}

sub initialize_test_data {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->new_other('TestUser')->init;
    foreach my $x (qw(WHEEL SPONSOR_EMP DISTRIBUTOR_EMP)) {
	$self->model(UserRegisterForm => {
	    'RealmOwner.display_name' => Freiker::Test->$x(),
	    'Address.zip' => Freiker::Test->ZIP,
	    'RealmOwner.name' => Freiker::Test->$x(),
	    'RealmOwner.password' => $self->TEST_PASSWORD,
	    'confirm_password' => $self->TEST_PASSWORD,
	    'Email.email' => $self->format_test_email(Freiker::Test->$x()),
	    password_ok => 1,
	});
    }
    $req->set_realm(undef);
    $req->with_user(Freiker::Test->WHEEL => sub {
	$self->model(ClubRegisterForm => {
	    club_name => Freiker::Test->SCHOOL,
	    'Address.zip' => Freiker::Test->ZIP,
	    'Website.url' => Freiker::Test->WEBSITE,
	    club_size => 32,
	});
    });
    $req->set_realm(Freiker::Test->SCHOOL_NAME);
    my($club_id) = $req->get('auth_id');
    foreach my $fm (map(Freiker::Test->FREIKOMETER($_), 0..1)) {
	$req->set_realm($club_id);
	$self->new_other('Freikometer')->create($fm);
	$self->req('auth_user')->update_password($self->TEST_PASSWORD);
    }
    $self->model(UserRegisterForm => {
	'RealmOwner.display_name' => Freiker::Test->PARENT,
	'Address.zip' => Freiker::Test->ZIP,
	'RealmOwner.name' => Freiker::Test->PARENT,
	'RealmOwner.password' => $self->TEST_PASSWORD,
	'confirm_password' => $self->TEST_PASSWORD,
	'Email.email' => $self->format_test_email(Freiker::Test->PARENT),
	password_ok => 1,
    });
    $req->set_realm($club_id);
    $self->new_other('Test')->reset_freikers;
    foreach my $x (qw(SPONSOR DISTRIBUTOR)) {
	my($e) = $x . '_EMP';
	$req->with_user(Freiker::Test->$e() => sub {
	    $self->model(MerchantInfoForm => {
		'RealmOwner.display_name' => Freiker::Test->$x(),
		'Address.zip' => Freiker::Test->ZIP,
		'Website.url' => Freiker::Test->WEBSITE,
		'Address.street1' => '123 Anywhere',
		'Address.city' => 'Boulder',
		'Address.state' => 'CO',
	    });
	});
    }
    $self->new_other('Test')->reset_prizes_for_school;
    $self->use('IO.File')->do_in_dir(site => sub {
        $self->new_other('RealmFile')
	    ->main(qw(-user adm -realm site import_tree));
    });
    return;
}

sub internal_upgrade_db_prize {
    my($self) = @_;
    my($req) = $self->req;
    $self->run(<<'EOF');
CREATE TABLE prize_t (
  prize_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(4000) NOT NULL,
  detail_uri VARCHAR(255) NOT NULL,
  ride_count NUMERIC(9) NOT NULL,
  retail_price NUMERIC(9) NOT NULL,
  prize_status NUMERIC(2) NOT NULL,
  CONSTRAINT prize_t1 PRIMARY KEY(prize_id)
)
/

CREATE TABLE prize_coupon_t (
  coupon_code NUMERIC(9) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  prize_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  ride_count NUMERIC(9) NOT NULL,
  CONSTRAINT prize_coupon_t1 PRIMARY KEY(realm_id, coupon_code)
)
/

CREATE TABLE prize_receipt_t (
  coupon_code NUMERIC(9) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  receipt_code NUMERIC(9) NOT NULL,
  CONSTRAINT prize_receipt_t1 PRIMARY KEY(realm_id, coupon_code)
)
/

CREATE TABLE prize_ride_count_t (
  prize_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  ride_count NUMERIC(9) NOT NULL,
  CONSTRAINT prize_ride_count_t1 PRIMARY KEY(prize_id, realm_id)
)
/

--
-- prize_t
--
ALTER TABLE prize_t
  ADD CONSTRAINT prize_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_t3 ON prize_t (
  realm_id
)
/
CREATE INDEX prize_t4 ON prize_t (
  modified_date_time
)
/
CREATE INDEX prize_t5 ON prize_t (
  name
)
/
CREATE INDEX prize_t6 ON prize_t (
  ride_count
)
/

--
-- prize_coupon_t
--
ALTER TABLE prize_coupon_t
  ADD CONSTRAINT prize_coupon_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_coupon_t3 ON prize_coupon_t (
  realm_id
)
/
ALTER TABLE prize_coupon_t
  ADD CONSTRAINT prize_coupon_t4
  FOREIGN KEY (prize_id)
  REFERENCES prize_t(prize_id)
/
CREATE INDEX prize_coupon_t5 ON prize_coupon_t (
  prize_id
)
/
ALTER TABLE prize_coupon_t
  ADD CONSTRAINT prize_coupon_t6
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX prize_coupon_t7 ON prize_coupon_t (
  user_id
)
/
CREATE INDEX prize_coupon_t8 ON prize_coupon_t (
  creation_date_time
)
/
CREATE INDEX prize_coupon_t9 ON prize_coupon_t (
  ride_count
)
/

--
-- price_ride_count_t
--
ALTER TABLE prize_ride_count_t
  ADD CONSTRAINT prize_ride_count_t2
  FOREIGN KEY (prize_id)
  REFERENCES prize_t(prize_id)
/
CREATE INDEX prize_ride_count_t3 ON prize_ride_count_t (
  prize_id
)
/
ALTER TABLE prize_ride_count_t
  ADD CONSTRAINT prize_ride_count_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_ride_count_t5 ON prize_ride_count_t (
  realm_id
)
/
CREATE INDEX prize_ride_count_t6 ON prize_ride_count_t (
  modified_date_time
)
/
CREATE INDEX prize_ride_count_t7 ON prize_ride_count_t (
  ride_count
)
/

--
-- prize_receipt_t
--
ALTER TABLE prize_receipt_t
  ADD CONSTRAINT prize_receipt_t2
  FOREIGN KEY (coupon_code, realm_id)
  REFERENCES prize_coupon_t(coupon_code, realm_id)
/
ALTER TABLE prize_receipt_t
  ADD CONSTRAINT prize_receipt_t3
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_receipt_t4 ON prize_receipt_t (
  realm_id
)
/
ALTER TABLE prize_receipt_t
  ADD CONSTRAINT prize_receipt_t5
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX prize_receipt_t6 ON prize_receipt_t (
  user_id
)
/
CREATE INDEX prize_receipt_t7 ON prize_receipt_t (
  creation_date_time
)
/
CREATE UNIQUE INDEX prize_receipt_t8 ON prize_receipt_t (
  realm_id,
  receipt_code
)
/
CREATE SEQUENCE prize_s
  MINVALUE 100021
  CACHE 1 INCREMENT BY 100000
/
EOF
    return;
}

1;
