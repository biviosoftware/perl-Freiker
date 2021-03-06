# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::TestData;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Freiker::Test;
use Freiker::Test::Freiker;

my($_D) = b_use('Type.Date');
my($_FF) = b_use('Type.FileField');
my($_SA) = b_use('Type.StringArray');
my($_RA) = b_use('ShellUtil.RealmAdmin');
my($_DT) = b_use('Type.DateTime');
my($_T) = b_use('Bivio.Test');
my($_TU) = b_use('ShellUtil.TestUser');
my($_FREIKER) = b_use('Auth.Role')->FREIKER;
my($_FM) = b_use('Type.FormMode');
my($_RT) = b_use('Type.RideType');

sub USAGE {
    return <<'EOF';
usage: fr-test [options] command [args..]
commands
  all_child_ride_dates [which [as_date]] -- all valid ride dates
  child_ride_dates [which [child [as_date]]] -- valid ride for the child (child(0) has many rides)
  reset_freikers [which] -- deletes and creates unregistered rides
  reset_freikometer_folders -- clears folders and sets up one download
  reset_need_accept_terms -- sets NEED_ACCEPT_TERMS RowTag for need-accept-terms user
  reset_prizes_for_school [which] -- create bunit10, bunit20, bunit50, bunit1000
EOF
}

sub all_child_ride_dates {
    my($self, $which, $as_date) = @_;
    return $self->child_ride_dates($which, 0, $as_date);
}

sub child_ride_dates {
    my($self, $which, $child_index, $as_date) = @_;
    $which ||= 0;
    $child_index ||= 0;
    return []
	unless $child_index <= $_T->MAX_CHILD_INDEX_WITH_RIDES
	    || (!$which && $child_index == $_T->NO_TAG_WITH_RIDES_CHILD_INDEX);
    my($now) = $_D->now;
    $as_date = $as_date ? sub {$_D->to_string(shift)} : sub {shift};
    return [map(
	$as_date->($_D->add_days($now, -$_)),
	$child_index ? $child_index : 0..99,
    )];
}

sub create_prize_coupon {
    my($self, $prize, $child) = shift->name_args([
	['prize', 'String'],
	['?child', 'String', 'child'],
    ], \@_);
    return $self->req->with_realm(
	$_T->SPONSOR_NAME,
	sub {
	    my($prize) = $self->model(Prize => {name => $prize});
	    return $self->model('PrizeCoupon')->create({
		realm_id => $self->model('PrizeSelectList')->get_distributor_id,
		user_id => $_RA->to_id($child),
		prize_id => $prize->get('prize_id'),
		ride_count => $prize->get('ride_count'),
	    });
	},
    )->get('coupon_code');
}

sub initialize_db {
    my($self) = @_;
    my($req) = $self->req;
    $_T = b_use('Bivio.Test');
    $self->new_other('TestUser')->init;
    foreach my $n (0..1) {
	$req->set_realm(undef);
	foreach my $x (qw(WHEEL SPONSOR_EMP)) {
	    _register_user(
		$self,
		$_T->$x($n),
		$_T->$x($n),
		$_T->ZIP($n),
	    );
	}
	$req->with_user($_T->WHEEL($n) => sub {
	    $_FM->CREATE->execute;
	    $self->model(ClubRegisterForm => {
		club_name => $_T->SCHOOL($n),
		'Address.zip' => $_T->ZIP($n),
		'Address.country' => $_T->COUNTRY,
		'Website.url' => $_T->WEBSITE($n),
		club_size => 32,
		'SchoolContact.display_name' => $_T->WHEEL($n),
		'SchoolContact.email' => $_TU->format_email($_T->WHEEL($n)),
		time_zone_selector => 'America/Denver',
		allow_tagless => $n ? 0 : 1,
	    });
	    foreach my $x (
		[qw(create FREIKOMETER)],
		[qw(create_zap ZAP ZAP_ETHERNET)],
		[qw(create_hub HUB)],
	    ) {
		my($method, $name, $display_name) = @$x;
		$req->set_realm($_T->SCHOOL_NAME($n));
		$self->new_other('Freikometer')->$method(
		    $_T->$name($n),
		    $display_name ? $_T->$display_name($n) : (),
		);
		$self->req('auth_user')->update_password($_TU->DEFAULT_PASSWORD);
	    }
	    return;
	});
	_register_user(
	    $self,
	    $_T->PARENT($n),
	    'A ' . ucfirst($_T->PARENT($n)),
	    $_T->ZIP($n),
	);
	$req->set_realm($_T->SCHOOL_NAME($n));
	# COUPLING: commit is to release Model.Lock on rides (above).
	$self->commit_or_rollback;
	foreach my $x (qw(SPONSOR)) {
	    my($e) = $x . '_EMP';
	    $req->with_user($_T->$e($n) => sub {
		$self->model(MerchantInfoForm => {
		    'RealmOwner.display_name' => $_T->$x($n),
		    'Address.zip' => $_T->ZIP($n),
		    'Website.url' => $_T->WEBSITE($n),
		    'Address.street1' => '123 Anywhere',
		    'Address.city' => 'Boulder',
		    'Address.state' => 'CO',
		});
	    });
	}
    }
    _register_user(
	$self,
	$_T->NEED_ACCEPT_TERMS,
	$_T->NEED_ACCEPT_TERMS,
	$_T->ZIP,
    );
    $self->new_other('TestData')->reset_need_accept_terms;
    _register_user(
	$self,
	$_T->CA_PARENT,
	'CA Parent',
	$_T->CA_ZIP,
	'CA',
    );
    $self->new_other('TestData')->reset_all_freikers;
    b_use('IO.File')->do_in_dir(site => sub {
	$self->new_other('RealmFile')
	    ->main(qw(-user adm -realm site import_tree));
    });
    return;
}

sub nudge_test_now {
    my($self) = @_;
    $_DT->set_test_now($_DT->add_seconds($_DT->now, 1), $self->req);
    return;
}

sub reset_all_freikers {
    my($self) = @_;
    foreach my $n (0..1) {
	$self->reset_freikers($n);
#TODO: Need this b/c Lock is set in reset, and can't have two locks on req
	$self->commit_or_rollback;
    }
    return;
}

sub reset_freikers {
    my($self, $which, $club_id, $req) = _setup_school(@_);
    $_DT->set_test_now($_T->TEST_NOW, $self->req);
    $self->reset_prizes_for_school($which);
    my($fc) = $self->model('FreikerCode');
    my($rides) = [];
    my($now) = $_D->now;
    my($indexes) = [0..$_T->MAX_CHILD_INDEX];
    $self->model('GreenGear')->delete_all({club_id => $self->req('auth_id')});
    $self->model('SchoolClass')->do_iterate(
	sub {
	    shift->cascade_delete;
	    return 1;
	},
	'unauth_iterate_start',
	{club_id => $club_id},
    );
    $self->model('SchoolYear')->test_unauth_delete_all({club_id => $club_id});
    foreach my $u (@{$self->model('RealmUser')->map_iterate(
	sub {shift->get('user_id')},
	'iterate_start',
	{role => $_FREIKER},
    )}) {
	$self->model('FreikerCode')->delete_all({
	    user_id => $u,
	});
	$req->with_realm($u => sub {
	    $self->model('Ride')->cascade_delete({
		user_id => $u,
	    });
	    $self->model('User')->unauth_delete_realm($u);
	});
    }
    $req->set_realm($club_id);
    my($scid);
    if ($which == 0) {
	$self->model('SchoolClassListForm')
	    ->process({
		map(
		    (
			"RealmOwner.display_name_$_" => $_T->TEACHER($_),
			"SchoolClass.school_grade_$_" => $_T->SCHOOL_GRADE($_),
		    ),
		    0..2,
		),
	    });
	$scid ||= $self->model('SchoolClassList')->load_with_school_year
	    ->find_by_teacher_name($_T->TEACHER(0))
	    ->get('SchoolClass.school_class_id');
    }
    foreach my $index (@$indexes) {
	my($code) = $_T->FREIKER_CODE($index, $which);
	my($epc) = $_T->EPC($index, $which);
	$fc->create_from_epc_and_code($epc, $code);
	$req->with_realm($_T->PARENT($which), sub {
	    # COUPLING: FreikerCodeForm checks FreikerRideList
	    $self->model('FreikerRideList')->delete_from_request;
	    _freiker_form($self, $which, $index, $club_id, $code);
	    $self->model('RealmUser')
		->create_freiker_unless_exists(
		    $self->req(qw(Model.FreikerInfo user_id)),
		    $scid,
		)
	        if $scid && $index == 0;
	    return;
	}) if $index <= 1 || $index == $_T->CHILD_WITHOUT_RIDES;
	$req->with_realm($_T->NEED_ACCEPT_TERMS, sub {
	    # COUPLING: FreikerCodeForm checks FreikerRideList
	    $self->model('FreikerRideList')->delete_from_request;
	    _freiker_form($self, $which, $index, $club_id, $code);
	    return;
	}) if $index == $_T->NEED_ACCEPT_TERMS_CHILD_INDEX;
	push(
	    @$rides,
	    map(+{epc => $epc, datetime => $_},
		@{$self->child_ride_dates($which, $index)}),
	) if $index <= $_T->MAX_CHILD_INDEX_WITH_RIDES;
    }
    my($fcif) = $self->model('FreikerCodeImportForm');
    foreach my $c (0 .. 9) {
	my($row) = $fc->generate_for_block($which + 1, $c);
	$fcif->process_record($row);
	$req->with_realm($_T->PARENT($which), sub {
	    # COUPLING: FreikerCodeForm checks FreikerRideList
	    $self->model('FreikerRideList')->delete_from_request;
	    $self->model('FreikerCodeForm', {
		'FreikerCode.freiker_code' => $row->{print},
		'Club.club_id' =>
		    $self->unauth_realm_id($_T->SCHOOL_NAME($which)),
		'User.first_name' => my $name = "generatedcode$which",
		'Address.zip' => $_T->ZIP($which),
		'Address.country' => $_T->COUNTRY,
		miles => $_T->DEFAULT_MILES,
		default_ride_type => $which ? $_RT->WALK : $_RT->UNKNOWN,
	    });
	}) unless $c || $which;
    }
    $req->with_user($_T->FREIKOMETER($which), sub {
	my($rif) = $self->model('RideImportForm');
	foreach my $r (@$rides) {
	    $rif->process_record($r);
	}
	return;
    });
#TODO: put in coupons not redeemed
    unless ($which) {
	map({
	    my($index) = $_T->MAX_CHILD_INDEX + $_;
	    $req->with_realm($_T->PARENT($which), sub {
		$self->model('FreikerRideList')->delete_from_request;
		$self->model(FreikerRideList => {
		    parent_id => $self->unauth_model(RealmOwner => {
			name => _freiker_form($self, $which, $index, $club_id),
		    })->get('realm_id'),
		});
		foreach my $d (@{$self->child_ride_dates($which, $index)}) {
		    $self->model('ManualRideForm')->process({
			'Ride.ride_date' => $d,
		    });
		}
	    })
	} (0 .. 1));
    }
    $req->with_realm($_T->PARENT($which), sub {
	my($code) = $_T->FREIKER_CODE(2, $which);
	my($index) = 1;
        $self->model(FreikerRideList => {
	    parent_id => $self->unauth_model(RealmOwner => {
		name => $_T->CHILD($index, $which),
	    })->get('realm_id'),
	});
	_freiker_form($self, $which, $index, $club_id, $code);
	$self->unauth_model(FreikerCode => {
	    freiker_code => $code,
	})->update({
	    modified_date_time => $_DT->add_seconds($_DT->now, 1),
	});
	return;
    });
    return;
}

sub reset_freikometer_folders {
    my($self) = @_;
    my($req) = $self->req;
    $req->assert_test;
    foreach my $p (map(
	@$_,
	map($self->model($_)->map_iterate(sub {shift->get('RealmFile.path')}),
	    qw(FreikometerDownloadList FreikometerUploadList)),
    )) {
	$self->model('RealmFile')->unauth_delete_deep({path => $p});
    }
    $req->with_realm($self->req('auth_id'), sub {
        $self->req->with_user($self->req('auth_id'), sub {
	    $self->new_other('Freikometer')->download({
		filename => 'test.sh',
		content_type => 'application/x-sh',
		content => \("date\n"),
	    });
	}),
    });
    return;
}

sub reset_freikometer_playlist {
    my($self) = @_;
    my($req) = $self->req;
    $req->assert_test;
    $req->with_realm($_T->FREIKOMETER, sub {
        $self->with_user($_T->FREIKOMETER, sub {
	    $self->new_other('Freikometer')->download({
		filename => 'playlist.pl',
		content_type => 'text/plain',
		content => \($self->internal_data_section),
	    });
	}),
    });
    return;
}

sub reset_need_accept_terms {
    my($self) = @_;
    $self->req->with_realm_and_user(
	$_T->NEED_ACCEPT_TERMS,
	undef,
	sub {
	    $self->model('RowTag')->replace_value(
		$self->req('auth_id'),
		'NEED_ACCEPT_TERMS',
		1,
	    );
	    my($addr) = $self->model('Address');
	    $addr->load->update({zip => undef});
	    $self->model('FreikerList')->do_iterate(sub {
	    	return $self->req->with_realm(
	    	    shift->get('RealmUser.user_id'),
	    	    sub {
	    		$self->model('Address')
	    		    ->load
	    		    ->update({zip => undef});
	    		$self->model('FreikerInfo')
	    		    ->load
	    		    ->update({distance_kilometers => undef});
	    		return 1;
	    	});
	    });
	    return;
	},
    );
    return;
}

sub reset_prizes_for_school {
    my($self, $which, $club_id, $req) = _setup_school(@_);
    $req->with_user($_T->ADM, sub {
	$req->with_realm($_T->SPONSOR_NAME($which), sub {
	    $self->model('Prize')->do_iterate(
		sub {
		    my($prize) = @_;
	            $self->model('PrizeCoupon')->do_iterate(
			sub {
			    shift->unauth_delete;
			    return 1;
			},
			'unauth_iterate_start',
			'prize_id',
			{prize_id => $prize->get('prize_id')},
		    );
		    $prize->cascade_delete;
		    return 1;
		},
		'unauth_iterate_start',
		'prize_id',
	    );
	    my($available) = b_use('Type.PrizeStatus')->AVAILABLE;
	    my($school) = $_T->SCHOOL_BASE($which);
	    foreach my $i (10, 20, 50, 99, 1000) {
		my($f) = $self->model('AdmPrizeForm');
		$f->process({
		    'Prize.name' => "$school$i",
		    'Prize.description' => "prize for $school $i",
		    'Prize.detail_uri' => "http://www.freiker.org?$i",
		    'Prize.ride_count' => $i,
		    'Prize.retail_price' => $i,
		    'Prize.prize_status' =>
			$i == 99 ? $available->UNAPPROVED : $available,
		    image_file => $_FF->from_disk(
			b_use('Freiker::Test::Freiker')
                            ->generate_image("prize$i"),
		    ),
		});
		$req->with_realm($club_id, sub {
		    $f->new_other('PrizeRideCount')->create_or_update({
			map(($_ => $f->get("Prize.$_")),
			    qw(ride_count prize_id)),
		    });
		});
	    }
	});
    });
    return;
}

sub _freiker_form {
    my($self, $which, $index, $club_id, $code) = @_;
    my($no_code) = defined($code) ? 0 : 1;
    $self->model(FreikerCodeForm => {
	'User.first_name' => my $name = $no_code
	    ? $_T->CHILD_NO_TAG($index, $which)
	    : $_T->CHILD($index, $which),
	'Club.club_id' => $club_id,
	'FreikerCode.club_id' => $club_id,
	'FreikerCode.freiker_code' => $code,
	no_freiker_code => $no_code,
	'User.gender' => $_T->DEFAULT_GENDER,
	birth_year => $_T->DEFAULT_BIRTH_YEAR,
	'Address.zip' => $_T->ZIP($which),
	'Address.country' => $_T->COUNTRY,
	miles => $_T->DEFAULT_MILES,
	default_ride_type => $which ? $_RT->WALK : $_RT->UNKNOWN,
    });
    $self->req('Model.RealmOwner')->update({name => $name});
    return $name;
}

sub _register_user {
    my($self, $name, $display_name, $zip, $country) = @_;
    $self->model(UserRegisterForm => {
	'RealmOwner.name' => $name,
	'RealmOwner.display_name' => $display_name,
	'Address.zip' => $zip,
	'Address.country' => $country || $_T->COUNTRY,
	'RealmOwner.password' => $_TU->DEFAULT_PASSWORD,
	'confirm_password' => $_TU->DEFAULT_PASSWORD,
	'Email.email' => $_TU->format_email($name),
	password_ok => 1,
    });
    return;
}

sub _setup_school {
    my($self, $which) = @_;
    $which ||= 0;
    my($req) = $self->req;
    $req->set_realm($_T->SCHOOL_NAME($which));
    return ($self, $which, $req->get('auth_id'), $req);
}

1;
__DATA__
{
  '0000000000ABCDEF000004D2' => 'default',
  '0000000000ABCDEF000004D3' => 'default',
  '0000000000ABCDEF000004D4' => 'default',
  '0000000000ABCDEF000004D5' => 'default',
  '0000000000ABCDEF000004D6' => 'default',
  '0000000000ABCDEF000004D7' => 'default',
  '0000000000ABCDEF000004D8' => 'default',
  '465245494B4552010003AE61' => 'green_gear',
  '465245494B4552010003B47C' => 'invalid',
  '465245494B4552010003AD61' => 'power_off',
  '465245494B4552010003BAB2' => 'reset_state',
  '465245494B4552010003A995' => 'default',
  '465245494B4552010003A999' => 'default',
  '465245494B4552010003AA29' => 'default',
  '465245494B4552010003AA72' => 'default',
  '465245494B4552010003AA85' => 'default',
  '465245494B4552010003AB24' => 'default',
  '465245494B4552010003AD0D' => 'default',
  '465245494B4552010003AD59' => 'default',
  '465245494B4552010003ADA2' => 'default',
  '465245494B4552010003ADD7' => 'default',
  '465245494B4552010003AE3B' => 'default',
  '465245494B4552010003AE76' => 'default',
  '465245494B4552010003AF61' => 'default',
  '465245494B4552010003AF94' => 'default',
  '465245494B4552010003AFAB' => 'default',
  '465245494B4552010003B13B' => 'default',
  '465245494B4552010003B202' => 'default',
  '465245494B4552010003B220' => 'default',
  '465245494B4552010003B268' => 'default',
  '465245494B4552010003B307' => 'default',
  '465245494B4552010003B317' => 'default',
  '465245494B4552010003B330' => 'default',
  '465245494B4552010003B38E' => 'default',
  '465245494B4552010003B39D' => 'default',
  '465245494B4552010003B39F' => 'default',
  '465245494B4552010003B3ED' => 'default',
  '465245494B4552010003B3F6' => 'default',
  '465245494B4552010003B473' => 'default',
  '465245494B4552010003B4BD' => 'default',
  '465245494B4552010003B4E0' => 'default',
  '465245494B4552010003B4EE' => 'default',
  '465245494B4552010003B4FD' => 'default',
  '465245494B4552010003B65F' => 'default',
  '465245494B4552010003B66A' => 'default',
  '465245494B4552010003B69B' => 'default',
  '465245494B4552010003B718' => 'default',
  '465245494B4552010003B7E2' => 'default',
  '465245494B4552010003B84E' => 'default',
  '465245494B4552010003B86E' => 'default',
  '465245494B4552010003B920' => 'default',
  '465245494B4552010003B9B6' => 'default',
  '465245494B4552010003BA52' => 'default',
  '465245494B4552010003BA55' => 'default',
  '465245494B4552010003BAAF' => 'default',
  '465245494B4552010003BB42' => 'default',
  '465245494B4552010003BB5E' => 'default',
  '465245494B4552010003BC0A' => 'default',
  '465245494B4552010003BE7B' => 'default',
  '465245494B4552010003BEEB' => 'default',
  '465245494B4552010003BF33' => 'default',
  '465245494B4552010003C022' => 'default',
  '465245494B4552010003C03C' => 'default',
  '465245494B4552010003C065' => 'default',
  '465245494B4552010003C096' => 'default',
  '465245494B4552010003C116' => 'default',
  '465245494B4552010003C132' => 'default',
  '465245494B4552010003C1D8' => 'default',
  '465245494B4552010003C1F6' => 'default',
  '465245494B4552010003C2FB' => 'default',
  '465245494B4552010003C380' => 'default',
  '465245494B4552010003C385' => 'default',
  '465245494B4552010003C3FC' => 'default',
  '465245494B4552010003C456' => 'default',
  '465245494B4552010003C462' => 'default',
  '465245494B4552010003C482' => 'default',
  '465245494B4552010003C486' => 'default',
  '465245494B4552010003C551' => 'default',
  '465245494B4552010003C5D7' => 'default',
  '465245494B4552010003C5FA' => 'default',
  '465245494B4552010003C624' => 'default',
  '465245494B4552010003C641' => 'default',
  '465245494B4552010003C6ED' => 'default',
  '465245494B4552010003C748' => 'default',
  '465245494B4552010003C7D8' => 'default',
  '465245494B4552010003C812' => 'default',
  '465245494B4552010003C871' => 'default',
  '465245494B4552010003C879' => 'default',
  '465245494B4552010003C8E4' => 'default',
  '465245494B4552010003C8FA' => 'default',
  '465245494B4552010003C9EB' => 'default',
  '465245494B4552010003CAFD' => 'default',
  '465245494B4552010003CB17' => 'default',
  '465245494B4552010003CB18' => 'default',
  '465245494B4552010003CB83' => 'default',
  '465245494B4552010003CB84' => 'default',
  '465245494B4552010003CC74' => 'default',
  '465245494B4552010003CCCA' => 'default',
  '465245494B4552010003CD11' => 'default',
  '465245494B4552010003CD8F' => 'default',
  '465245494B4552010003CE2C' => 'default',
  '465245494B4552010003CE30' => 'default',
  '465245494B4552010003CE71' => 'default',
  '465245494B4552010003CF19' => 'default',
  '465245494B4552010003CF77' => 'default',
  '465245494B4552010003D041' => 'default',
  '465245494B4552010003D047' => 'default',
};

