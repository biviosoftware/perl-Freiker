# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::MerchantPrizeForm;
use strict;
use Bivio::Base 'Model.ImageUploadForm';


sub LIST_MODEL {
    return 'MerchantPrizeList';
}

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->load_from_model_properties($req->get('Model.Prize'))
	if $req->get('Type.FormMode')->eq_edit;
    return;
}

sub execute_ok {
    my($self) = shift;
    my($req) = $self->get_request;
    my($edit) =  $req->get('Type.FormMode')->eq_edit;
    my($p) = $edit ? $req->get_nested('Model.Prize')
	: $self->new_other('Prize');
    my($m) = $edit ? 'update' : 'create';
    $self->load_from_model_properties(
	$p->$m($self->get_model_properties('Prize')),
    );
    return $self->SUPER::execute_ok(@_);
}

sub internal_image_is_required {
    return shift->get_request->get('Type.FormMode')->eq_create;
}

sub internal_image_max_height {
    return 150;
}

sub internal_image_max_width {
    return 150;
}

sub internal_image_path {
    return shift->get_request->get('Model.Prize')->image_path;
}

sub internal_image_properties {
    return {
	%{shift->SUPER::internal_image_properties(@_)},
	override_is_read_only => 1,
	is_read_only => 1,
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    'Prize.name',
	    'Prize.description',
	    'Prize.detail_uri',
	    'Prize.retail_price',
	],
	other => [
	    'Prize.prize_id',
	    {
		name => 'full_edit',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = shift;
    $self->use('Type.FormMode')->setup_by_list_this(
	$self->new_other($self->LIST_MODEL), 'Prize');
    return $self->SUPER::internal_pre_execute(@_);
}

1;
