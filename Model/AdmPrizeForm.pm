# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmPrizeForm;
use strict;
use Bivio::Base 'Model.MerchantPrizeForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LIST_MODEL {
    return 'AdmPrizeList';
}

sub execute_ok {
    return shift->call_super_before(\@_, sub {
        my($self) = @_;
	# New prize: Add to all clubs, even though unapproved
	$self->new_other('ClubList')->do_iterate(sub {
            $self->new_other('PrizeRideCount')->unauth_create_or_update({
	        prize_id => $self->get('Prize.prize_id'),
	        realm_id => shift->get('Club.club_id'),
	        ride_count => $self->get('Prize.ride_count'),
	    });
	    return 1;
        });
        return;
    });
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [qw(
	    Prize.ride_count
	    Prize.prize_status
	)],
    });
}

1;
