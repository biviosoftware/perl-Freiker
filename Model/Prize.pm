# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Prize;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IFN) = Bivio::Type->get_instance('ImageFileName');
my($_PS) = Bivio::Type->get_instance('PrizeStatus');

sub cascade_delete {
    my($self) = shift;
    $self->new_other('PrizeRideCount')->do_iterate(
	sub {
	    shift->unauth_delete;
	    return 1;
	},
	'unauth_iterate_start',
	'prize_id',
	{prize_id => $self->get('prize_id')},
    );
    $self->new_other('RealmFile')->delete({
	path => $self->image_path,
	override_is_read_only => 1,
    });
    return $self->SUPER::cascade_delete(@_);
}

sub create {
    my($self, $values) = @_;
    $values->{ride_count} ||= 0;
    $values->{prize_status} ||= $_PS->UNAPPROVED;
    return shift->SUPER::create(@_);
}

sub image_path {
    my(undef, $model, $model_prefix, $values) = shift->internal_get_target(@_);
    return $_IFN->to_absolute(
	$values->{$model_prefix . 'prize_id'} . '.jpg', 1);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'prize_t',
	columns => {
	    prize_id => ['PrimaryId', 'PRIMARY_KEY'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
	    name => ['Line', 'NOT_NULL'],
	    description => ['LongText', 'NOT_NULL'],
	    detail_uri => ['HTTPURI', 'NOT_NULL'],
	    ride_count => ['RideCount', 'NOT_NULL'],
	    retail_price => ['Dollars', 'NOT_NULL'],
	    prize_status => ['PrizeStatus', 'NOT_NULL'],
	},
    });
}

1;
