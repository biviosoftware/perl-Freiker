# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeListForm;
use strict;
$Freiker::Model::BarcodeListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::BarcodeListForm::VERSION;

=head1 NAME

Freiker::Model::BarcodeListForm - students who need names

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::BarcodeListForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Freiker::Model::BarcodeListForm::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Freiker::Model::BarcodeListForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Loads properties from list model

=cut

sub execute_empty_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    $self->internal_put_field(
	'Class.class_id' => $lm->get('RealmUser_2.realm_id')
	    || $lm->EMPTY_KEY_VALUE);
    return;
}

=for html <a name="execute_ok_row"></a>

=head2 execute_ok_row()

Enter records

=cut

sub execute_ok_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    return if $self->get('Class.class_id')
	eq ($lm->get('RealmUser_2.realm_id') || $lm->EMPTY_KEY_VALUE);
    my($ru) = $self->new_other('RealmUser');
    $ru->unauth_delete({
	realm_id => $lm->get('RealmUser_2.realm_id'),
	user_id => $lm->get('RealmUser.user_id'),
	role => Bivio::Auth::Role->STUDENT,
    }) if $lm->get('RealmUser_2.realm_id');
    $ru->create({
	realm_id => $self->get('Class.class_id'),
	user_id => $lm->get('RealmUser.user_id'),
	role => Bivio::Auth::Role->STUDENT,
    }) if $self->get('Class.class_id') ne $lm->EMPTY_KEY_VALUE;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	list_class => 'BarcodeList',
	visible => [
	    {
		name => 'Class.class_id',
		in_list => 1,
		constraint => 'NONE',
	    },
	],
	primary_key => ['RealmOwner.name'],
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
