# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::MerchantPrizeForm;
use strict;
use Bivio::Base 'Model.ImageUploadForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PS) = Bivio::Type->get_instance('PrizeStatus');

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
    unless ($req->is_substitute_user || $req->is_super_user) {
	$self->internal_put_field('Prize.prize_status' => $_PS->UNAPPROVED);
	$self->internal_put_field(
	    'Prize.ride_count' => $edit ? $p->get('ride_count') : 0);
    }
    $self->load_from_model_properties(
	$p->$m($self->get_model_properties('Prize')),
    );
    $self->SUPER::execute_ok(@_);
    return if $p;
    # New prize: Add to all clubs, even though unapproved
    $self->new_other('ClubList')->do_iterate(sub {
        $self->new_other('PrizeRideCount')->create({
	    prize_id => $self->get('Prize.prize_id'),
	    realm_id => shift->get('Club.club_id'),
	});
	return 1;
    });
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
	    'Prize.retail_price',
	    map(+{name => $_, constraint => 'NONE'},
		qw(Prize.ride_count Prize.prize_status)),
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
