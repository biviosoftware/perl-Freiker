# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::AdmFreikerCodeReallocateForm;
use strict;
use Bivio::Base 'Model.ConfirmableForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FC) = b_use('Model.FreikerCode');

sub execute_ok {
    my($self) = @_;
    my($source_club_id) = $self->get('source.Club.club_id');
    my($dest_club_id) = $self->get('dest.Club.club_id');
    return $self->internal_put_error('dest.Club.club_id' => 'SYNTAX_ERROR')
	if $source_club_id eq $dest_club_id;
    my($block) = $_FC->get_block_for_code(
	$self->get('FreikerCode.freiker_code'));
    my($codes) = $self->new_other('FreikerCode')->map_iterate(sub {
        my($fc) = @_;
	return $fc->clone
	    if $_FC->get_block_for_code($fc->get('freiker_code')) eq $block;
	return ();
    }, 'unauth_iterate_start', {
	club_id => $source_club_id,
    });
    return $self->internal_put_error('FreikerCode.freiker_code' => 'NOT_FOUND')
	unless my $num_tags = scalar(@$codes);
    foreach my $c (@$codes) {
	return $self->internal_put_error('FreikerCode.freiker_code' => 'EXISTS')
	    if defined($self->new_other('FreikerInfo')->unauth_load_or_die({
		user_id => $c->get('user_id'),
	    })->get('distance_kilometers'));
    }
    foreach my $x (qw(source dest)) {
	$self->req->with_realm($self->get("$x.Club.club_id"), sub {
	    $self->internal_put_field("$x.RealmOwner.display_name" =>
		$self->new_other('RealmOwner')->load->get('display_name'));
	});
    };
    $self->internal_put_field(num_tags => $num_tags);
    $self->internal_put_field(tag_block => $block);
    $self->check_redirect_to_confirmation_form(
	'ADM_FREIKER_CODE_REALLOCATE_CONFIRM');
    foreach my $c (@$codes) {
	$c->update({
	    club_id => $dest_club_id,
	});
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'FreikerCode.freiker_code',
	    'source.Club.club_id',
	    'dest.Club.club_id',
	],
	other => [
	    'source.RealmOwner.display_name',
	    'dest.RealmOwner.display_name',
	    {
		name => 'num_tags',
		type => 'Integer',
		constraint => 'NONE',
	    },
	    {
		name => 'tag_block',
		type => 'Integer',
		constraint => 'NONE',
	    },
	],
    });
}

1;
