# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Test;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Freiker::Test;
use Freiker::Test::Freiker;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');
my($_FF) = Bivio::Type->get_instance('FileField');
my($_SA) = __PACKAGE__->use('Type.StringArray');
my($_RA) = __PACKAGE__->use('ShellUtil.RealmAdmin');
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: fr-test [options] command [args..]
commands
  reset_freikers -- deletes and creates unregistered rides
  reset_freikometer_folders -- clears folders and sets up one download
  reset_prizes_for_school -- create bunit10, bunit20, bunit50, bunit1000
EOF
}

sub reset_freikers {
    my($self) = @_;
    my($req) = $self->req;
    $self->reset_prizes_for_school;
    $req->set_realm(Freiker::Test->SCHOOL_NAME);
    my($club_id) = $req->get('auth_id');
    my($fc) = $self->model('FreikerCode');
    my($rides) = [];
    my($now) = $_D->now;
    my($indexes) = [0..6];
    foreach my $u (@{$_SA->sort_unique([
	map(
	    $fc->unsafe_load({
		freiker_code => Freiker::Test->FREIKER_CODE($_),
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
	my($code) = Freiker::Test->FREIKER_CODE($index);
	my($epc) = Freiker::Test->EPC($index);
	$fc->create_from_epc_and_code($epc, $code);
	$req->with_realm(Freiker::Test->PARENT, sub {
	    $self->model(FreikerForm => {
		'User.first_name' => my $name = Freiker::Test->CHILD($index),
		'Club.club_id' => $club_id,
		'FreikerCode.club_id' => $club_id,
		'FreikerCode.freiker_code' => Freiker::Test->FREIKER_CODE($index),
		'User.gender' => $self->use('Type.Gender')->FEMALE,
		'birth_year' => 1999,
	    });
	    $self->req('Model.RealmOwner')->update({name => $name});
	    return;
	}) if $index <= 1 || $index == 6;
	push(@$rides, map(+{
	    epc => $epc,
	    datetime => $_D->add_days($now, -$_),
	}, ($index ? $index : 0..99)))
	    unless $index == 6;
    }
    $req->with_user(Freiker::Test->FREIKOMETER, sub {
	my($rif) = $self->model('RideImportForm');
	foreach my $r (@$rides) {
	    $rif->process_record($r);
	}
	return;
    });
#put in coupons not redeemed
    $req->with_realm(Freiker::Test->PARENT, sub {
        $self->model(FreikerRideList => {
	    parent_id => $self->unauth_model(RealmOwner => {name => 'child1'})
		->get('realm_id'),
	});
        $self->model(FreikerCodeForm => {
	    'Club.club_id' => $club_id,
	    'FreikerCode.freiker_code' => Freiker::Test->FREIKER_CODE(2),
	});
	$self->unauth_model(FreikerCode => {
	    freiker_code => Freiker::Test->FREIKER_CODE(2),
	})->update({
	    modified_date_time => $_DT->add_seconds($_DT->now, 1),
	});
	return;
    });
    return;
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
    my($self) = @_;
    my($req) = $self->req;
    $req->assert_test;
    $req->with_user(Freiker::Test->ADM, sub {
	$req->with_realm(Freiker::Test->SPONSOR_NAME, sub {
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
	    my($available) = $self->use('Type.PrizeStatus')->AVAILABLE;
	    foreach my $i (10, 20, 50, 99, 1000) {
		my($f) = $self->model('AdmPrizeForm');
		$f->process({
		    'Prize.name' => "bunit$i",
		    'Prize.description' => "prize for bunit $i",
		    'Prize.detail_uri' => "http://www.freiker.org?$i",
		    'Prize.ride_count' => $i,
		    'Prize.retail_price' => $i,
		    'Prize.prize_status' =>
			$i == 99 ? $available->UNAPPROVED : $available,
		    image_file => $_FF->from_disk(
			Freiker::Test::Freiker->generate_image("prize$i"),
		    ),
		});
		$req->with_realm(Freiker::Test->SCHOOL_NAME, sub {
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
