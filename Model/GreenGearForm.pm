# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GreenGearForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_I) = b_use('Type.Integer');
my($_D) = b_use('Type.Date');
my($_R) = b_use('Biz.Random');
my($_DT) = b_use('Type.DateTime');

sub execute_empty {
    my($self) = @_;
    my($begin, $end) = _prev_begin_end($self);
    $self->internal_put_field(
	'GreenGear.begin_date' => $begin, 'GreenGear.end_date' => $end);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($users) = _check_count($self);
    return $self->internal_put_error(qw(GreenGear.begin_date EMPTY))
	unless %$users;
    return $self->internal_put_error(qw(GreenGear.begin_date UNSUPPORTED_TYPE))
	unless %{$users = _check_registered($self, $users)};
    return $self->internal_put_error(qw(GreenGear.begin_date EXISTS))
	unless %{$users = _check_unique($self, $users)};
    my($uid) = _choose([keys(%$users)]);
    $self->create_model_properties(GreenGear => {user_id => $uid});
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [qw(
	    GreenGear.begin_date
	    GreenGear.end_date
	    GreenGear.must_be_registered
	    GreenGear.must_be_unique
	)],
	auth_id => 'GreenGear.club_id',
    });
}

sub validate {
    my($self) = @_;
    return
	if $self->in_error;
    foreach my $d (qw(GreenGear.begin_date GreenGear.end_date)) {
	return $self->internal_put_error($d => 'TOO_MANY')
	    if $_D->compare($self->get($d), $_D->now) > 0;
    }
    my($begin, $end) = $self->get(qw(GreenGear.begin_date GreenGear.end_date));
    return $self->internal_put_error(qw(GreenGear.begin_date MUTUALLY_EXCLUSIVE))
	if $_D->compare($begin, $end) > 0;
    if (my $ggl = _list($self)) {
	$self->internal_put_error(qw(GreenGear.begin_date GREATER_THAN_ZERO))
	    if $_D->compare($ggl->get('GreenGear.end_date'), $begin) >= 0;
    }
    return;
}

sub _check_count {
    my($self) = @_;
    my($max);
    return {@{$self->new_other('ClubRideCountList')->map_iterate(
	sub {
	    my($i, $c) = shift->get(qw(Ride.user_id ride_count));
	    $max = $c
		unless defined($max);
	    return $c == $max ? ($i => $c) : ();
	},
	{map(($_ => $self->get("GreenGear.$_")), qw(begin_date end_date))},
    )}};
}

sub _check_registered {
    my($self, $users) = @_;
    return $users
	unless $self->get('GreenGear.must_be_registered');
    my($ru) = $self->new_other('RealmUser');
    return {map(
	@$_,
	grep(
	    $_->[1],
	    map([$_ => $ru->unsafe_family_id_for_freiker($_)], keys(%$users)),
	),
    )};
}

sub _check_unique {
    my($self, $users) = @_;
    return $users
	unless $self->get('GreenGear.must_be_unique');
    my($gg) = $self->new_other('GreenGear');
    return {map(
	($_ => $users->{$_}),
	grep(!$gg->unsafe_load_first({user_id => $_}), keys(%$users)),
    )};
}

sub _choose {
    my($choices) = @_;
    return $choices->[$_R->integer(scalar(@$choices))];
}

sub _list {
    my($self) = @_;
    my($ggl) = $self->new_other('GreenGearList')->load_page({count => 1});
    return $ggl->get_result_set_size ? $ggl->set_cursor_or_die(0) : undef;
}

sub _prev_begin_end {
    my($self) = @_;
    if (my $ggl = _list($self)) {
	my($gg) = $ggl->get_model('GreenGear');
	$self->internal_put_field(map(
	    ("GreenGear.$_" => $gg->get($_)),
	    qw(must_be_registered must_be_unique),
	));
	return _this_begin_end($self, $gg->get(qw(begin_date end_date)));
    }
    $self->internal_put_field(
	'GreenGear.must_be_unique' => 1,
	'GreenGear.must_be_registered' => 1,
    );
    my($end) = _two_fridays_ago();
    return (_search_dow($end, 'Monday', -1), $end);
}

sub _search_dow {
    my($value, $dow, $inc) = @_;
    $value = $_DT->add_days($value, $inc)
	while $_DT->english_day_of_week($value) ne $dow;
    return $value;
}

sub _this_begin_end {
    my($self, $begin, $end) = @_;
    my($days) = int($_D->delta_days($begin, $end) + 0.1);
    return ($begin = $_D->add_months($begin, 1), $_D->set_end_of_month($begin))
	if $days > 14;
    $days = $days == 0 ? 1
	: $days <= 7 ? 7
	: $days <= 14 ? 14
	: 28;
    $end = $_D->add_days($end, $days);
    $begin = $_D->add_days($end, -$days);
    if ($days > 1) {
	$begin = _search_dow($begin, 'Monday', +1);
	$end = _search_dow($_D->add_days($begin, $days), 'Friday', -1)
    }
    return ($begin, $end);
}

sub _two_fridays_ago {
    my($now) = $_D->now;
    my($friday) = _search_dow($now, 'Friday', -1);
    $friday = _search_dow($_D->add_days($friday, -1), 'Friday', -1)
	if $friday eq $now;
    return $friday;
}

1;
