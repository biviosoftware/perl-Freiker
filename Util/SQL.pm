# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use Bivio::Base 'ShellUtil';
use Bivio::Test::Language::HTTP;
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

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
	    _register_user(
		$self,
		Freiker::Test->$x($n),
		Freiker::Test->$x($n),
		Freiker::Test->ZIP($n),
	    );
	}
	$req->with_user(Freiker::Test->WHEEL($n) => sub {
	    $self->model(ClubRegisterForm => {
		club_name => Freiker::Test->SCHOOL($n),
		'Address.zip' => Freiker::Test->ZIP($n),
		'Website.url' => Freiker::Test->WEBSITE($n),
		club_size => 32,
	    });
	    foreach my $x (
		[qw(create FREIKOMETER)],
		[qw(create_zap ZAP ZAP_ETHERNET)],
	    ) {
		my($method, $name, $display_name) = @$x;
		$req->set_realm(Freiker::Test->SCHOOL_NAME($n));
		$self->new_other('Freikometer')->$method(
		    Freiker::Test->$name($n),
		    $display_name ? Freiker::Test->$display_name($n) : (),
		);
		$self->req('auth_user')->update_password($self->TEST_PASSWORD);
	    }
	    return;
	});
	_register_user(
	    $self,
	    Freiker::Test->PARENT($n),
	    'A ' . ucfirst(Freiker::Test->PARENT($n)),
	    Freiker::Test->ZIP($n),
	);
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
    }
    _register_user(
	$self,
	Freiker::Test->NEED_ACCEPT_TERMS,
	Freiker::Test->NEED_ACCEPT_TERMS,
	Freiker::Test->ZIP,
    );
    $self->new_other('TestData')->reset_need_accept_terms;
    _register_user(
	$self,
	Freiker::Test->CA_PARENT,
	'CA Parent',
	Freiker::Test->CA_ZIP,
	'CA',
    );
    $self->new_other('TestData')->reset_all_freikers;
    b_use('IO.File')->do_in_dir(site => sub {
	$self->new_other('RealmFile')
	    ->main(qw(-user adm -realm site import_tree));
    });
    return;
}

sub internal_upgrade_db_feature_group_admin {
    my($self) = @_;
    foreach my $rt (qw(CLUB MERCHANT)) {
	$self->add_permissions_to_realm_type(
	    b_use('Auth.RealmType')->$rt(),
	    ['FEATURE_GROUP_ADMIN'],
	);
    }
    return shift->SUPER::internal_upgrade_db_feature_group_admin(@_);
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

sub internal_upgrade_db_freikometer_members {
    my($self) = @_;
    $self->new_other('Freikometer')->do_all(sub {
	$self->new_other('RealmRole')->edit_categories('+feature_file');
	$self->new_other('RealmRole')->edit(qw(MEMBER -DATA_WRITE));
	$self->new_other('RealmRole')->do_super_users(
	    sub {$self->new_other('Freikometer')->join_user_as_member},
	);
	return;
    });
    return;
}

sub internal_upgrade_db_need_accept_terms {
    my($self) = @_;
    $self->model('Email')->do_iterate(
	sub {
	    $self->model('RowTag')->replace_value(
		shift->get('realm_id'),
		NEED_ACCEPT_TERMS => 1,
	    );
	    return 1;
	},
	'unauth_iterate_start',
	'email',
    );
    return;
}

sub internal_upgrade_db_ride_club_id {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE ride_t
    ADD COLUMN club_id NUMERIC(18)
/
EOF
    my($map) = {@{$self->model('RealmOwner')->map_iterate(
	sub {
	    my($cid) = shift->get('realm_id');
	    return
		if b_use('Auth.Realm')->is_default_id($cid); 
	    return $self->req->with_realm(
		$cid,
		sub {
		    return @{$self->model('RealmUserList')->map_iterate(
			sub {shift->get('RealmUser.user_id') => $cid},
			{roles => [b_use('Auth.Role')->FREIKER]},
		    )};
		},
	    );
	},
	'unauth_iterate_start',
	'realm_id',
	{realm_type => b_use('Auth.RealmType')->CLUB},
    )}};
    $self->model('Ride')->do_iterate(
	sub {
	    my($it) = @_;
	    $it->update({
		club_id => $map->{$it->get('user_id')} || b_die($it->get_shallow_copy),
	    });
	    return 1;
	},
	'unauth_iterate_start',
	'user_id',
    );
    $self->run(<<'EOF');
ALTER TABLE ride_t
    ALTER COLUMN club_id SET NOT NULL
/
CREATE INDEX ride_t7 ON ride_t (
  club_id
)
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t8
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
EOF
    return;
}

sub _register_user {
    my($self, $name, $display_name, $zip, $country) = @_;
    $self->model(UserRegisterForm => {
	'RealmOwner.name' => $name,
	'RealmOwner.display_name' => $display_name,
	'Address.zip' => $zip,
	'Address.country' => $country || 'US',
	'RealmOwner.password' => $self->TEST_PASSWORD,
	'confirm_password' => $self->TEST_PASSWORD,
	'Email.email' => $self->format_test_email($name),
	password_ok => 1,
    });
    return;
}

1;
