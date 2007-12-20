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

sub internal_upgrade_db_club_aux {
    my($self) = @_;
    my($req) = $self->req;
    $self->run(<<'EOF');
DROP TABLE club_aux_t
/
EOF
    return;
}

1;
