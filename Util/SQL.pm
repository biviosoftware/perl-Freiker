# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use Bivio::Base 'ShellUtil';
use Bivio::Test::Language::HTTP;
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'fr']);
}

sub initialize_db {
    return shift->call_super_before(\@_, sub {
        my($self) = @_;
	$self->new_other('SiteForum')->init;
	$self->internal_upgrade_db_freiker_distributor;
        return;
    });
}

sub init_realm_role {
    return shift->call_super_before(\@_, sub {
        my($self) = @_;
	my($rr) = $self->new_other('RealmRole');
	foreach my $realm (qw(general user club)) {
	    $self->set_realm_and_user($realm, 'user');
	    $rr->edit(ADMINISTRATOR => '+RIDE_WRITE');
	    $rr->edit(FREIKOMETER => qw(+USER +RIDE_WRITE));
	}
	$self->new_other('RealmRole')->copy_all(forum => 'merchant');
        return;
    });
}

sub initialize_test_data {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->new_other('TestUser')->init;
    foreach my $n (0..1) {
	$req->set_realm(undef);
	foreach my $x (qw(WHEEL SPONSOR_EMP)) {
	    $self->model(UserRegisterForm => {
		'RealmOwner.display_name' => Freiker::Test->$x($n),
		'Address.zip' => Freiker::Test->ZIP($n),
		'RealmOwner.name' => Freiker::Test->$x($n),
		'RealmOwner.password' => $self->TEST_PASSWORD,
		'confirm_password' => $self->TEST_PASSWORD,
		'Email.email' => $self->format_test_email(
		    Freiker::Test->$x($n)),
		password_ok => 1,
	    });
	}
	$req->with_user(Freiker::Test->WHEEL($n) => sub {
	    $self->model(ClubRegisterForm => {
		club_name => Freiker::Test->SCHOOL($n),
		'Address.zip' => Freiker::Test->ZIP($n),
		'Website.url' => Freiker::Test->WEBSITE($n),
		club_size => 32,
	    });
	    $req->set_realm(Freiker::Test->SCHOOL_NAME($n));

	    $self->new_other('Freikometer')->create(
		Freiker::Test->FREIKOMETER($n));
	    $self->req('auth_user')->update_password($self->TEST_PASSWORD);
	    return;
	});
	$self->model(UserRegisterForm => {
	    'RealmOwner.display_name' => 'A ' . ucfirst(Freiker::Test->PARENT($n)),
	    'Address.zip' => Freiker::Test->ZIP($n),
	    'RealmOwner.name' => Freiker::Test->PARENT($n),
	    'RealmOwner.password' => $self->TEST_PASSWORD,
	    'confirm_password' => $self->TEST_PASSWORD,
	    'Email.email' => $self->format_test_email(Freiker::Test->PARENT($n)),
	    password_ok => 1,
	});
	$req->set_realm(Freiker::Test->SCHOOL_NAME($n));
	# COUPLING: commit is to release Model.Lock on rides (above).
	$self->commit_or_rollback;
	foreach my $x (qw(SPONSOR)) {
	    my($e) = $x . '_EMP';
	    $req->with_user(Freiker::Test->$e($n) => sub {
		$self->model(MerchantInfoForm => {
		    'RealmOwner.display_name' => Freiker::Test->$x($n),
		    'Address.zip' => Freiker::Test->ZIP($n),
		    'Website.url' => Freiker::Test->WEBSITE($n),
		    'Address.street1' => '123 Anywhere',
		    'Address.city' => 'Boulder',
		    'Address.state' => 'CO',
		});
	    });
	}
	$self->new_other('TestData')->reset_freikers($n);
    }
    $self->use('IO.File')->do_in_dir(site => sub {
	$self->new_other('RealmFile')
	    ->main(qw(-user adm -realm site import_tree));
    });
    return;
}

sub internal_upgrade_db_green_gear {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE green_gear_t (
  club_id NUMERIC(18) NOT NULL,
  begin_date DATE NOT NULL,
  end_date DATE NOT NULL,
  must_be_registered NUMERIC(1) NOT NULL,
  must_be_unique NUMERIC(1) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT green_gear_t1 PRIMARY KEY(club_id, begin_date)
)
/
CREATE INDEX green_gear_t2 ON green_gear_t (
  club_id
)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t3
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX green_gear_t4 ON green_gear_t (
  user_id
)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t5
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX green_gear_t6 ON green_gear_t (
  end_date
)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t7
  CHECK (must_be_registered BETWEEN 0 AND 1)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t8
  CHECK (must_be_unique BETWEEN 0 AND 1)
/
CREATE INDEX green_gear_t9 ON green_gear_t (
  creation_date_time
)
/
EOF
    return;
}

sub internal_upgrade_db_freiker_distributor {
    my($self) = @_;
    my($req) = $self->req;
    $req->with_realm(undef, sub {
	my($ral) = $self->model('RealmAdminList')->load_all
	    ->set_cursor_or_not_found(0);
	$req->with_user(
	    $ral->get('RealmUser.user_id'),
	    sub {
		$self->model('MerchantInfoForm', {
		    'RealmOwner.display_name' => 'Freiker, Inc.',
		    'Address.street1' => '2701 Iris Ave, Suite S',
		    'Address.city' => 'Boulder',
		    'Address.state' => 'CO',
		    'Address.zip' => '803042435',
		    'Website.url' => 'http://www.freiker.org',
		});
		$ral->do_rows(sub {
	            $self->model(RealmUserAddForm => {
			administrator => 1,
			'RealmUser.realm_id' => $self->req(qw(Model.Merchant merchant_id)),
			'User.user_id' => $ral->get('RealmUser.user_id'),
		    }),
	        });
		return;
	    },
	),
    });
    return;
}

1;
