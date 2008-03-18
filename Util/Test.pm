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
    });
    $req->with_realm(Freiker::Test->PARENT, sub {
        $self->model(FreikerRideList => {
	    parent_id => $self->unauth_model(RealmOwner => {name => 'child1'})
		->get('realm_id'),
	});
        $self->model(FreikerCodeForm => {
	    'Club.club_id' => $club_id,
	    'FreikerCode.freiker_code' => Freiker::Test->FREIKER_CODE(2),
	});
    });
    return;
}

sub reset_freikometer_folders {
    my($self) = @_;
    $self->req->assert_test;
    foreach my $p (map(
	@$_,
	map($self->model($_)->map_iterate(sub {shift->get('RealmFile.path')}),
	    qw(FreikometerDownloadList FreikometerUploadList)),
    )) {
	$self->model('RealmFile')->unauth_delete_deep({path => $p});
    }
    $self->set_realm_and_user(
	Freiker::Test->FREIKOMETER,
	Freiker::Test->FREIKOMETER,
    );
    $self->new_other('Freikometer')->download({
	filename => 'test.sh',
	content_type => 'application/x-sh',
	content => \("date\n"),
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
	            $self->model('PrizeCoupon')->do_iterate(sub {
		        shift->unauth_delete;
		        return 1;
		    }, 'unauth_iterate_start','prize_id', {
		        prize_id => $prize->get('prize_id'),
		    });
		    $prize->cascade_delete;
		    return 1;
		},
		'prize_id',
	    );
	    my($available) = $self->use('Type.PrizeStatus')->AVAILABLE;
	    foreach my $i (10, 20, 50, 99, 1000) {
		my($f) = $self->model('MerchantPrizeForm');
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
