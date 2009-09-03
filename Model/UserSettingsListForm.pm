# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::UserSettingsListForm;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FCF) = b_use('Model.FreikerCodeForm');
my($_DEFAULT_LOCATION) = b_use('Model.Address')->DEFAULT_LOCATION;

sub execute_empty {
    my($self) = @_;
    my($m) = $self->new_other('Address');
    $self->load_from_model_properties($m)
	if $m->unsafe_load;
    return shift->SUPER::execute_empty(@_);
}

sub execute_ok {
    my($self) = @_;
    $self->create_or_update_model_properties('Address');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    $self->field_decl(
		[qw(Address.country Address.zip)],
		undef,
		'NOT_NULL',
	    ),
	],
	other => [
	    'Address.location',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field('Address.location' => $_DEFAULT_LOCATION);
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    $_FCF->validate_address($self);
    return;
}

1;
