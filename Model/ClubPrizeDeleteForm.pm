# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClubPrizeDeleteForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self, $req) = @_;
#TODO: Note that didn't delete PrizeReceipt.  Reason is that we need to
#      consider what "store returns" mean.  Will need to log the entries Part
#      of audit structure is to track debits/credits like a real accounting
#      structure and never do a delete
    $self->req('Model.PrizeCoupon')->delete;
#TODO: Make FormModel method that returns "no query".  This is good enough for now
    return {task_id => 'next'};
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($cl) = $self->new_other('ClubPrizeCouponList');
    $cl->load_this($cl->parse_query_from_request)
	->get_model('PrizeCoupon');
    return shift->SUPER::internal_pre_execute(@_);
}

1;
