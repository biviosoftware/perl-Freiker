# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AllClubRideDateList;
use strict;
use Bivio::Base 'Model.ClubRideDateList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{auth_id});
    return $self->merge_initialize_info($info, {
        version => 1,
	primary_key => ['RealmOwner.name', 'Ride.ride_date'],
        group_by => ['RealmOwner.name', 'RealmOwner.display_name'],
	other => [
	    [{
		name => 'FreikerCode.club_id',
		in_select => 0,
	    }, 'RealmOwner.realm_id'],
	    'RealmOwner.display_name',
	    'RealmOwner.name',
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(
	$stmt->GT('Ride.ride_date', [$_D->add_days($_D->now, -60)]));
    return;
}

1;
