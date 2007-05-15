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
  reset_rides_for_child_0 -- give 100 rides to child_0
EOF
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
	    {freiker_code => Freiker::Test->FREIKER_CODE},
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
    });
    return;
}

1;
