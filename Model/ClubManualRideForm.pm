# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubManualRideForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = __PACKAGE__->use('ShellUtil.Freiker');
my($_D) = __PACKAGE__->use('Type.Date');

sub execute_ok {
    my($self) = @_;
    my($frl) = $self->req('Model.FreikerRideList');
    my($uid) = $frl->get_query->get('parent_id');
    my($rides) = [map(
	$_D->from_literal_or_die($_),
	@{$_F->missing_rides(
	    $self->new_other('UserFreikerCodeList')
	    ->get_most_recent($uid))},
    )];
    foreach my $n (1 .. $self->get('add_days')) {
	$self->new_other('ManualRideForm')->process({
	    'Ride.ride_date' => shift(@$rides),
	});
    }
    return {
	task_id => 'next',
	query => {
	    'ListQuery.parent_id' => $uid,
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'add_days',
		type => 'RideCount',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('FreikerRideList')
	->execute_load_all_with_query($self->req);
    return;
}

1;
