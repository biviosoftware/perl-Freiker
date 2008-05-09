# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubPrizeConfirmForm;
use strict;
use Bivio::Base 'Model.PrizeConfirmForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PRIZE_SELECT_LIST {
    return 'ClubPrizeSelectList';
}

sub execute_ok {
    my($self) = shift;
    $self->SUPER::execute_ok(@_);
    $self->new_other($self->PRIZE_SELECT_LIST)
	->execute_load_for_user_and_credit($self->req);
    my($psl) = $self->req('Model.' . $self->PRIZE_SELECT_LIST);
    return $psl->get_result_set_size ? {
	task_id => 'next',
	query => {
	    'ListQuery.parent_id' => $psl->get_query->get('parent_id'),
	},
    } : 'cancel';
}

1;
