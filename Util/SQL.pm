# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use base 'Bivio::Util::SQL';
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
	$self->internal_upgrade_db_merchant_realm_type;
        return;
    });
}

sub initialize_test_data {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->new_other('TestUser')->init;
    foreach my $x (qw(WHEEL SPONSOR_EMP)) {
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
    # COUPLING: commit is to release Model.Lock on rides (above).
    $self->commit_or_rollback;
    foreach my $x (qw(SPONSOR)) {
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
    $self->new_other('Test')->reset_freikers;
    $self->use('IO.File')->do_in_dir(site => sub {
        $self->new_other('RealmFile')
	    ->main(qw(-user adm -realm site import_tree));
    });
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

sub internal_upgrade_db_merchant_realm_type {
    my($self) = @_;
    $self->new_other('RealmRole')->copy_all(forum => 'merchant');
    return;
}

1;
