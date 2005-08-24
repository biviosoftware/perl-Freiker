# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::SchoolRegisterForm;
use strict;
$Freiker::Model::SchoolRegisterForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::SchoolRegisterForm::VERSION;

=head1 NAME

Freiker::Model::SchoolRegisterForm - register wheel and school

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::SchoolRegisterForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::UserCreateForm>

=cut

use Bivio::Biz::Model::UserCreateForm;
@Freiker::Model::SchoolRegisterForm::ISA = ('Bivio::Biz::Model::UserCreateForm');

=head1 DESCRIPTION

C<Freiker::Model::SchoolRegisterForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_create_models"></a>

=head2 internal_create_models() : array

Creates School and zip.

=cut

sub internal_create_models {
    my($self) = @_;
    my($realm, @rest) = shift->SUPER::internal_create_models(@_);
    $self->new_other('RealmUser')->create({
	user_id => $realm->get('realm_id'),
        role => Bivio::Auth::Role->ADMINISTRATOR,
	realm_id => $self->new_other('Address')->create({
	    zip => $self->get('zip'),
	    realm_id => $self->new_other('RealmOwner')->create({
		display_name => $self->get('school_name'),
		realm_type => Bivio::Auth::RealmType->SCHOOL,
		realm_id => $self->new_other('School')->create(
		    $self->get_model_properties('School'),
		)->get('school_id'),
	    })->get('realm_id'),
	})->get('realm_id'),
    });
    return ($realm, @rest);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    @{$self->internal_initialize_local_fields(
		[
		    [school_name => 'RealmOwner.display_name'],
		    [zip => 'USZipCode9'],
		],
		undef,
		'NOT_NULL',
	    )},
	    'School.website',
	],
    });
}

=for html <a name="validate"></a>

=head2 validate()

school name is unique wrt zip.

=cut

sub validate {
    my($self) = @_;
    return if $self->in_error;
    my($r) = $self->new_other('RealmOwner');
    return unless $r->unauth_load({
	display_name => $self->get('school_name'),
	realm_type => Bivio::Auth::RealmType->SCHOOL,
    });
    my($a) = $self->new_other('Address');
    return unless $a->unauth_load({
	zip => $self->get('zip'),
    });
    $self->internal_put_error('school_name', 'EXISTS');
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
