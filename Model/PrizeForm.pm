# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PrizeForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    if (my $m = $self->get_request->unsafe_get('Model.Prize')) {
	$self->load_from_model_properties($m);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($p) = $req->unsafe_get('Model.Prize');
    my($m) = $p ? 'update' : 'create';
    ($p || $self->new_other('Prize'))->$m($self->get_model_properties);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Prize.name',
	    'Prize.description',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($l) = $self->new_other('PrizeList');
    my($q) = $l->parse_query_from_request;
    $l->get_model('Prize')
	if $q->get('this') && $l->unsafe_load_this($q);
    return shift->SUPER::internal_pre_execute(@_);
}

1;
