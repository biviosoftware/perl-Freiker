# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::MerchantPrizeForm;
use strict;
use Bivio::Base 'Model.ImageUploadForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub IMAGE_FILE_IS_REQUIRED {
    return 0;
}

sub execute_empty {
    my($self) = @_;
    if (my $p = $self->get_request->unsafe_get('Model.Prize')) {
	$self->load_from_model_properties($p);
    }
    return;
}

sub execute_ok {
    my($self) = shift;
    $self->create_or_update_from_properties('Prize');
    $self->SUPER::execute_ok(@_);
    return;
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
    return shift->get_request->get('Model.Prize')->image_file_name;
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
	    'Prize.ride_count',
	    {
		name => 'image',
		type => 'FileField',
		constraint => 'NONE',
	    },
	],
	other => [
	    'Prize.prize_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = shift;
    $self->use('Type.FormMode')->setup_by_list_this(
	$self->new_other('MerchantPrizeList'), 'Prize');
    return $self->SUPER::internal_pre_execute(@_);
}

1;
