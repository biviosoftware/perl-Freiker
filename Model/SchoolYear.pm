# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolYear;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub REALM_ID_FIELD {
    return 'club_id';
}

sub create_this_year_unless_exists {
    my($self) = @_;
    my($v) = {
	club_id => $self->req('auth_id'),
	start_date => $self->this_year_start_date,
    };
    return $self->unauth_load($v) ? $self : $self->create($v);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'school_year_t',
	columns => {
	    school_year_id => ['PrimaryId', 'PRIMARY_KEY'],
	    start_date => ['Date', 'NOT_NULL'],
	},
    });
}

sub this_year_start_date {
    my($y, $m) = $_D->get_parts($_D->now, 'year', 'month');
    return _start_date($y + ($m <= 6 ? -1 : 0));
}

sub unsafe_load_last_year_as_new {
    my($self) = @_;
    my($other) = $self->new;
    return $other->unsafe_load({
	start_date => $_D->add_years($self->get('start_date'), -1)})
	? $other : undef;
}

sub _start_date {
    my($year) = @_;
    return $_D->date_from_parts(1, 8, $year);
}

1;
