# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::UserFreikerCodeList;
use strict;
use Bivio::Base 'Model.FreikerCodeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_display_name {
    my($self, $user_id) = @_;
    return '(' . join(
	', ',
	@{$self->unauth_load_all({auth_id => $user_id})->map_rows(
	    sub {shift->get('FreikerCode.freiker_code')})},
    ) . ')';
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
