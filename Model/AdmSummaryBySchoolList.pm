# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmSummaryBySchoolList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_K) = b_use('Type.Kilometers');
my($_FL) = b_use('Model.FreikerList');

sub FIELDS {
    return qw(RealmOwner.realm_id
	      RealmOwner.display_name);
}

sub RIDE_MODEL {
    return 'AdmRideList';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['RealmOwner.realm_id'],
	other => [
	    $self->field_decl([
		[qw(realm_display_name String)],
		[qw(ride_count Integer)],
		[qw(current_miles Integer)],
		[qw(current_kilometers Kilometers)],
		[qw(calories Integer)],
		[qw(co2_saved Integer)],
	    ]),
	],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($realms) = {};
    # ->load_all->do_rows is faster than ->do_iterate for large data sets
    $self->new_other($self->RIDE_MODEL)->load_all->do_rows(sub {
	my($rid, $dn, $d) = shift->get($self->FIELDS, 'FreikerInfo.distance_kilometers');
	$rid ||= 0;
	$d ||= 0;
	($realms->{$rid} ||= {})->{'RealmOwner.realm_id'} ||= $rid;
	$realms->{$rid}->{'realm_display_name'} ||= $dn;
	($realms->{$rid}->{'ride_count'} ||= 0)++;
	($realms->{$rid}->{'current_kilometers'} ||= 0) += 2 * $d;
	return 1;
    });
    foreach my $r (keys(%$realms)) {
	my($m) = $_K->to_miles($realms->{$r}->{'current_kilometers'});
	$realms->{$r}->{'current_miles'} = $m;
	$realms->{$r}->{'calories'} = $m * $_FL->CALORIES_PER_MILE;
	$realms->{$r}->{'co2_saved'} = $m * $_FL->CO2_POUNDS_PER_MILE;
    }
    my($rows) = [];
    map(push(@$rows, $realms->{$_}),
	sort({$realms->{$a}->{'realm_display_name'}
		  cmp $realms->{$b}->{'realm_display_name'}} keys(%$realms)));
    return $rows;
}

1;
