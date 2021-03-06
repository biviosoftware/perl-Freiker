# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::UserFreikerCodeList;
use strict;
use Bivio::Base 'Model.FreikerCodeList';


sub get_codes {
    my($self, $user_id) = @_;
    return $self->unauth_load_all({auth_id => $user_id})->map_rows(
	sub {shift->get('FreikerCode.freiker_code')});
}

sub get_display_name {
    my($self, $uid_or_codes) = @_;
    $uid_or_codes = $self->get_codes($uid_or_codes)
	unless ref($uid_or_codes);
    return '(' . join(', ', @$uid_or_codes) . ')'
	unless @$uid_or_codes <= 0;
    return '';
}

sub get_most_recent {
    my($self, $user_id) = @_;
    return $self->unauth_load_all({auth_id => $user_id})->set_cursor_or_die(0)
	->get('FreikerCode.freiker_code');
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{order_by});
    return $self->merge_initialize_info($info, {
        version => 1,
	auth_id => ['FreikerCode.user_id'],
	order_by => ['FreikerCode.modified_date_time'],
    });
}

1;
