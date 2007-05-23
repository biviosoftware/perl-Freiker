# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Test;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Freiker::Test;
use Freiker::Test::Freiker;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');

sub USAGE {
    return <<'EOF';
usage: fr-test [options] command [args..]
commands
  reset_prizes_for_school -- create bunit10, bunit20, bunit50, bunit1000
  reset_rides_for_child_0 -- give 100 rides to child_0
EOF
}

sub reset_prizes_for_school {
    my($self) = @_;
    my($req) = $self->get_request;
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
		    image_file => $f->format_file_field(
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

sub reset_rides_for_child_0 {
    my($self) = @_;
    $self->get_request->with_realm(Freiker::Test->CHILD, sub {
	my($r) = $self->model('Ride');
	$r->do_iterate(
	    sub {
		shift->delete;
		return 1;
	    },
	    'freiker_code',
	);
	my($v) = {
	    is_manual_entry => 0,
	    freiker_code => Freiker::Test->FREIKER_CODE,
	    ride_date => $_D->local_today,
	};
	foreach my $i (1..100) {
	    $v->{ride_date} = $_D->add_days($v->{ride_date}, -1);
	    $r->create($v);
	}
	$r->new_other('PrizeCoupon')->do_iterate(
	    sub {
		shift->cascade_delete;
		return 1;
	    },
	    'coupon_code',
	);
    });
    return;
}

1;
