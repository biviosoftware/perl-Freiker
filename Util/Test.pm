# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Test;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Freiker::Test;

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
    $req->with_realm(Freiker::Test->SPONSOR_NAME, sub {
	my($p) = $self->model('Prize');
	$p->do_iterate(
	    sub {
		shift->cascade_delete;
		return 1;
	    },
	    'prize_id',
	);
	my($value) = {
	    name => 'bunit',
	    description => 'prize for bunit ',
	    detail_uri => 'http://www.apple.com/ipodnano',
	};
	foreach my $i (10, 20, 50, 99, 1000) {
	    my($v) = {%$value};
	    $v->{name} .= $i;
	    $v->{description} .= $i;
	    $v->{ride_count} = $i;
	    $v->{retail_price} = $i;
	    $v->{prize_status} = $self->use('Type.PrizeStatus')->from_name(
		$i == 99 ? 'UNAPPROVED' : 'AVAILABLE');
	    $p->create($v);
	    $req->with_realm(Freiker::Test->SCHOOL_NAME, sub {
		$p->new_other('PrizeRideCount')->create({
		    map(($_ => $p->get($_)), qw(ride_count prize_id)),
		});
	    });
	}
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
