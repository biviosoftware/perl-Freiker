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
    return shift->call_super_before(\@_, sub {
        shift->new_other('SiteForum')->init;
	return;
    });
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
	    'ClubAux.website' => Freiker::Test->WEBSITE,
	    'ClubAux.club_size' => 32,
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

sub internal_upgrade_db_freiker_code {
    my($self) = @_;
    my($req) = $self->req;
    my($rides) = do('Ride.pl') || die($@);
    my($freiker_codes) = do('FreikerCode.pl') || die($@);
    my($uploads) = [];
    my($code_to_user) = {map(
	($_->{freiker_code} => $_->{realm_id}),
	grep($_->{realm_id} =~ /001/, @$rides),
    )};
    my($code_to_club) = {map(
	($_->{freiker_code} => $_->{club_id}),
	@$freiker_codes,
    )};
    my($realm_users) = {};
    $self->model('RealmUser')->do_iterate(
	sub {
	    my($copy) = shift->get_shallow_copy;
	    push(@{$realm_users->{$copy->{user_id}} ||= []}, $copy);
	    return 1;
	},
	'unauth_iterate_start',
	'creation_date_time desc',
	{role => Bivio::Auth::Role->MEMBER},
    );
    my($freikometers) = {};
    $self->model('RealmUser')->do_iterate(
	sub {
	    my($r, $u) = shift->get(qw(realm_id user_id));
	    push(@{$freikometers->{$r} ||= []}, $u);
	    return 1;
	},
	'unauth_iterate_start',
	'creation_date_time desc',
	{role => Bivio::Auth::Role->FREIKOMETER},
    );
    my($old_epc) = $self->use('Type.OldEPC');
    my($user) = $self->model('User');
    my($now) = $self->use('Type.DateTime')->now;
    my($auth_id) = '';
    my($zip);
    my($exists) = {};
    foreach my $fc (sort {$a->{club_id} cmp $b->{club_id}} @$freiker_codes) {
	unless ($auth_id eq $fc->{club_id}) {
	    $req->set_realm($auth_id = $fc->{club_id});
	    $zip = $self->model('Address')->load->get('zip');
	}
	my($code) = $fc->{freiker_code};
	$fc->{epc} = $old_epc->new($zip, $code)->as_string;
	if ($fc->{user_id} = $code_to_user->{$code}) {
	    my($ru) = $self->model('RealmUser');
	    foreach my $copy (@{$realm_users->{$fc->{user_id}}}) {
		next if $exists->{$copy->{user_id} . ' ' . $copy->{realm_id}}++;
		$ru->unauth_delete($copy);
		$ru->create({
		    %$copy,
		    role => Bivio::Auth::Role->FREIKER,
		});
		$fc->{modified_date_time} = $copy->{creation_date_time};
	    }
	}
	else {
	    $code_to_user->{$code}
		= $fc->{user_id} = $user->create_freiker($code);
	    $fc->{modified_date_time} = $now;
	}
    }
    my($ride_uploads) = {};
    $exists = {};
    foreach my $r (sort {$a->{creation_date_time} cmp $b->{creation_date_time}} @$rides) {
	$r->{ride_upload_id} = $ride_uploads->{$r->{creation_date_time}} ||= {
	    club_id => $code_to_club->{$r->{freiker_code}} || die('1'),
	    creation_date_time => $r->{creation_date_time} || die('2'),
	    freikometer_user_id => $freikometers->{$code_to_club->{$r->{freiker_code}}}->[0] || die('3'),
	} unless $r->{is_manual_entry};
	$r->{user_id} = $code_to_user->{$r->{freiker_code}}
	    || die($r->{freiker_code});
	Bivio::IO::Alert->info($r->{user_id} . ' ' . $r->{ride_date} . ' ' . $r->{freiker_code})
	    if $exists->{$r->{user_id} . ' ' . $r->{ride_date}}++;
    }
    $self->run(<<'EOF');
DROP TABLE ride_t
/
DROP TABLE freiker_code_t
/
EOF
    $self->run(<<'EOF');
CREATE TABLE freiker_code_t (
  club_id NUMERIC(18) NOT NULL,
  freiker_code NUMERIC(9) NOT NULL,
  epc CHAR(24) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  CONSTRAINT freiker_code_t1 PRIMARY KEY(freiker_code)
)
/
CREATE TABLE ride_t (
  user_id NUMERIC(18) NOT NULL,
  ride_date DATE NOT NULL,
  ride_time DATE NOT NULL,
  ride_upload_id NUMERIC(18),
  CONSTRAINT ride_t1 PRIMARY KEY(user_id, ride_date)
)
/

CREATE TABLE ride_upload_t (
  ride_upload_id NUMERIC(18) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  freikometer_user_id NUMERIC(18) NOT NULL,
  CONSTRAINT ride_upload_t1 PRIMARY KEY(ride_upload_id)
)
/
CREATE SEQUENCE ride_upload_s
  MINVALUE 100022
  CACHE 1 INCREMENT BY 100000
/
CREATE INDEX freiker_code_t2 ON freiker_code_t (
  club_id
)
/
ALTER TABLE freiker_code_t
  ADD CONSTRAINT freiker_code_t3
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX freiker_code_t4 ON freiker_code_t (
  user_id
)
/
ALTER TABLE freiker_code_t
  ADD CONSTRAINT freiker_code_t5
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE UNIQUE INDEX freiker_code_t6 ON freiker_code_t (
  epc
)
/
CREATE INDEX freiker_code_t7 ON freiker_code_t (
  modified_date_time
)
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX ride_t3 ON ride_t (
  user_id
)
/
CREATE INDEX ride_t4 ON ride_t (
  ride_date
)
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t5
  FOREIGN KEY (ride_upload_id)
  REFERENCES ride_upload_t(ride_upload_id)
/
CREATE INDEX ride_t6 ON ride_t (
  ride_upload_id
)
/

--
-- ride_upload_id
--
ALTER TABLE ride_upload_t
  ADD CONSTRAINT ride_upload_t2
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX ride_upload_t3 ON ride_upload_t (
  club_id
)
/
ALTER TABLE ride_upload_t
  ADD CONSTRAINT ride_upload_t4
  FOREIGN KEY (freikometer_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX ride_upload_t5 ON ride_upload_t (
  freikometer_user_id
)
/
CREATE INDEX ride_upload_t4 ON ride_upload_t (
  creation_date_time
)
/
EOF
    foreach my $r (values(%$ride_uploads)) {
	$r->{ride_upload_id} = $self->model('RideUpload')->create($r)
	    ->get('ride_upload_id');
    }
    foreach my $fc (@$freiker_codes) {
	$self->model('FreikerCode')->create($fc);
    }
    foreach my $r (@$rides) {
	$r->{ride_upload_id} = $r->{ride_upload_id}->{ride_upload_id} || die
	    if $r->{ride_upload_id};
	$self->model('Ride')->create($r);
    }
    return;
}

1;
