# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::TestData;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Freiker::Test;
use Freiker::Test::Freiker;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_FF) = b_use('Type.FileField');
my($_SA) = b_use('Type.StringArray');
my($_RA) = b_use('ShellUtil.RealmAdmin');
my($_DT) = b_use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: fr-test [options] command [args..]
commands
  all_child_ride_dates [as_date] -- all valid ride dates
  child_ride_dates [child [as_date]] -- valid ride for the child (child(0) has many rides)
  reset_freikers [which] -- deletes and creates unregistered rides
  reset_freikometer_folders -- clears folders and sets up one download
  reset_need_accept_terms -- sets NEED_ACCEPT_TERMS RowTag for need-accept-terms user
  reset_prizes_for_school [which] -- create bunit10, bunit20, bunit50, bunit1000
EOF
}

sub all_child_ride_dates {
    return shift->child_ride_dates(0, @_);
}

sub child_ride_dates {
    my($self, $child_index, $as_date) = @_;
    $child_index ||= 0;
    return []
	if $child_index == Freiker::Test->MAX_CHILD_INDEX;
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
	Freiker::Test->SPONSOR_NAME,
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

sub nudge_test_now {
    my($self) = @_;
    $_DT->set_test_now($_DT->add_seconds($_DT->now, 1), $self->req);
    return;
}

sub reset_need_accept_terms {
    my($self) = @_;
    $self->req->with_realm(
	Freiker::Test->NEED_ACCEPT_TERMS,
	sub {
	    $self->model('RowTag')->replace_value(
		$self->req('auth_id'),
		'NEED_ACCEPT_TERMS',
		1,
	    );
	    $self->model('Address')->load->update({
		zip => undef,
	    });
	    return;
	},
    );
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
    $_DT->set_test_now(Freiker::Test->TEST_NOW, $self->req);
    $self->reset_prizes_for_school($which);
    my($fc) = $self->model('FreikerCode');
    my($rides) = [];
    my($now) = $_D->now;
    my($indexes) = [0..Freiker::Test->MAX_CHILD_INDEX];
    $self->model('GreenGear')->cascade_delete({});
    foreach my $u (@{$_SA->sort_unique([
	map(
	    $fc->unsafe_load({
		freiker_code => Freiker::Test->FREIKER_CODE($_, $which),
	    }) ? ($fc->get('user_id'), $fc->delete)[0] : (),
	    @$indexes,
	),
    ])}) {
	$req->with_realm($u => sub {
	    $self->model('Ride')->cascade_delete({});
	    $self->model('User')->unauth_delete_realm($u);
	});
    }
    $req->set_realm($club_id);
    foreach my $index (@$indexes) {
	my($code) = Freiker::Test->FREIKER_CODE($index, $which);
	my($epc) = Freiker::Test->EPC($index, $which);
	$fc->create_from_epc_and_code($epc, $code);
	$req->with_realm(Freiker::Test->PARENT($which), sub {
	    # COUPLING: FreikerCodeForm checks FreikerRideList
	    $self->model('FreikerRideList')->delete_from_request;
	    _freiker_form($self, $which, $index, $club_id, $code);
	    return;
	}) if $index <= 1 || $index == Freiker::Test->MAX_CHILD_INDEX_WITH_RIDES;
	push(
	    @$rides,
	    map(+{epc => $epc, datetime => $_},
		@{$self->child_ride_dates($index)}),
	) unless $index >= Freiker::Test->MAX_CHILD_INDEX_WITH_RIDES;
    }
    $req->with_user(Freiker::Test->FREIKOMETER($which), sub {
	my($rif) = $self->model('RideImportForm');
	foreach my $r (@$rides) {
	    $rif->process_record($r);
	}
	return;
    });
#TODO: put in coupons not redeemed
    $req->with_realm(Freiker::Test->PARENT($which), sub {
	my($code) = Freiker::Test->FREIKER_CODE(2, $which);
	my($index) = 1;
        $self->model(FreikerRideList => {
	    parent_id => $self->unauth_model(RealmOwner => {
		name => Freiker::Test->CHILD($index, $which),
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
    $req->with_realm(Freiker::Test->FREIKOMETER, sub {
        $self->req->with_user(Freiker::Test->FREIKOMETER, sub {
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
    $req->with_realm(Freiker::Test->FREIKOMETER, sub {
        $self->with_user(Freiker::Test->FREIKOMETER, sub {
	    $self->new_other('Freikometer')->download({
		filename => 'playlist.pl',
		content_type => 'text/plain',
		content => \($self->internal_data_section),
	    });
	}),
    });
    return;
}

sub reset_prizes_for_school {
    my($self, $which, $club_id, $req) = _setup_school(@_);
    $req->with_user(Freiker::Test->ADM, sub {
	$req->with_realm(Freiker::Test->SPONSOR_NAME($which), sub {
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
	    my($school) = Freiker::Test->SCHOOL_BASE($which);
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
			Freiker::Test::Freiker->generate_image("prize$i"),
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
    $self->model(FreikerCodeForm => {
	'User.first_name' =>
	    my $name = Freiker::Test->CHILD($index, $which),
	'Club.club_id' => $club_id,
	'FreikerCode.club_id' => $club_id,
	'FreikerCode.freiker_code' => $code,
	'User.gender' => Freiker::Test->DEFAULT_GENDER,
	birth_year => Freiker::Test->DEFAULT_BIRTH_YEAR,
	'Address.zip' => Freiker::Test->ZIP($which),
	miles => Freiker::Test->DEFAULT_MILES,
    });
    $self->req('Model.RealmOwner')->update({name => $name});
    return;
}

sub _setup_school {
    my($self, $which) = @_;
    $which ||= 0;
    my($req) = $self->req;
    $req->set_realm(Freiker::Test->SCHOOL_NAME($which));
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
