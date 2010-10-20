# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AllClubSummaryList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = b_use('Type.RealmName');
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');
my($_FLQF) = b_use('Model.FreikerListQueryForm');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['RealmOwner.display_name'],
	date => 'Ride.ride_date',
	other => [
	    _days(sub {
		my($sum, undef, $rank) = @_;
		return map(+{
		    name => $_,
		    type => 'Integer',
		    constraint => 'NOT_NULL',
		}, $sum, $rank);
	    }),
	],
	other_query_keys => [qw(fr_begin fr_end fr_all)],
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($names) = {};
    my($counts) = {};
    my($max_date) = {};
    my($show_all) = $self->show_all;
    $self->new_other('AllClubRideDateList')->do_iterate(
	sub {
	    my($n, $dn, $c, $d) = shift->get(qw(
		RealmOwner.name RealmOwner.display_name ride_count Ride.ride_date));
	    return 1
		if !$show_all && $dn =~ /\bdemo\b/i;
	    push(@{$counts->{$n} ||= []}, $c);
	    $names->{$n} ||= $dn;
	    $max_date->{$n} = $d
		if !$max_date->{$n} || $_DT->compare($d, $max_date->{$n}) > 0;
	    return 1;
	},
	{
	    begin_date => $_FLQF->get_value_fr($self, 'fr_begin')
		|| $_D->add_days($_D->now, -60),
	    date => $_FLQF->get_value_fr($self, 'fr_end')
		|| $_D->now,
	},
    );
    my($max_max_date) = $_DT->max(values(%$max_date));
    unless ($show_all) {
	foreach my $n (keys(%$names)) {
	    delete($names->{$n})
		if $_DT->delta_days($max_date->{$n}, $max_max_date) > 30;
	}
    }
    return _rank([sort(
	{
	    $b->{days_20} <=> $a->{days_20}
		|| lc($a->{'RealmOwner.display_name'})
		  cmp lc($b->{'RealmOwner.display_name'})
	}
        map({
	    my($n) = $_;
	    {
		'RealmOwner.display_name' => $_RN->strip_school_classifiers(
		    $names->{$n}),
		_days(sub {shift, _sum($counts->{$n}, shift)}),
	    };
	} keys(%$names)),
    )]);
}

sub show_all {
    return $_FLQF->get_value_fr(shift, 'fr_all') ? 1 : 0;
}

sub _days {
    my($op) = @_;
    return map($op->("days_$_", $_, "rank_days_$_"), qw(1 5 20 10000));
}

sub _rank {
    my($rows) = @_;
    _days(sub {
        my($sum, undef, $rank) = @_;
	my($i) = 1;
	map($_->{$rank} = $i++,
	    sort({$b->{$sum} <=> $a->{$sum}} @$rows),
	);
	return;
    });
    return $rows;
}

sub _sum {
    my($counts, $days, $ranks) = @_;
    my($sum) = 0;
    foreach my $i (0 .. $days - 1) {
	$sum += $counts->[$i] || 0;
    }
    return $sum;
}

1;
