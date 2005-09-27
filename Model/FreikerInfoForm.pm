# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerInfoForm;
use strict;
$Freiker::Model::FreikerInfoForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::FreikerInfoForm::VERSION;

=head1 NAME

Freiker::Model::FreikerInfoForm - x

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::FreikerInfoForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Freiker::Model::FreikerInfoForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Freiker::Model::FreikerInfoForm>

=cut

=head1 CONSTANTS

=cut

=for html <a name="EMPTY_NAME"></a>

=head2 EMPTY_NAME : string

=cut

sub EMPTY_NAME {
    return ' ';
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

=cut

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties('RealmOwner');
    my($r) = $self->new_other('RealmUser');
    $self->internal_put_field('Class.class_id' => _id($self));
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

=cut

sub execute_ok {
    my($self) = @_;
    $self->update(
	$self->get_request->get('auth_id'),
	$self->get('RealmOwner.display_name', 'Class.class_id'),
    );
    Bivio::Biz::Action->get_instance('Acknowledgement')
        ->save_label('freiker_info', $self->get_request)
	unless $self->in_error;
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
	visible => [
	    ['Class.class_id', 'RealmUser.realm_id'],
	    'RealmOwner.display_name',
	],
	auth_id => [qw(RealmOwner.realm_id RealmUser.user_id)],
    });
}

=for html <a name="internal_pre_execute"></a>

=head2 internal_pre_execute()

=cut

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('ClassSelectList')->unauth_load_all({
	auth_id => $self->new_other('RealmUser')->unauth_load_or_die({
	    user_id => $self->get_request->get('auth_id'),
	    role => Bivio::Auth::Role->FREIKER,
	})->get('realm_id'),
    });
    return;
}

=for html <a name="update"></a>

=head2 update(string user_id, string display_name, string new_class_id, string old_class_id)

I<old_class_id> is optional.  It'll be looked up otherwise.  Uses
I<EMPTY_KEY_VALUE> from ClassSelectList.

=cut

sub update {
    my($self, $user_id, $display_name, $new_class_id, $old_class_id) = @_;
    $self->new_other('RealmOwner')->unauth_load_or_die({
	realm_id => $user_id,
    })->update({
	display_name => $display_name || $self->EMPTY_NAME,
    });
    $old_class_id ||= _id($self);
    return if $new_class_id eq $old_class_id;
    my($ek) = $self->get_instance('ClassSelectList')->EMPTY_KEY_VALUE;
    my($ru) = $self->new_other('RealmUser');
    $ru->unauth_delete({
	realm_id => $old_class_id,
	user_id => $user_id,
	role => Bivio::Auth::Role->STUDENT,
    }) unless $ek eq $old_class_id;
    $ru->create({
	realm_id => $new_class_id,
	user_id => $user_id,
	role => Bivio::Auth::Role->STUDENT,
    }) unless $ek eq $new_class_id;
    return;
}

=for html <a name="validate"></a>

=head2 validate()

Make sure in the list of classes.

=cut

sub validate {
    my($self) = @_;
    return if $self->in_error;
    $self->internal_put_error('Class.class_id' => 'NULL')
	unless $self->get_request->get('Model.ClassSelectList')->find_row_by_id(
	    $self->get('Class.class_id'),
	);
    return;
}

#=PRIVATE SUBROUTINES

# _id(self) : string
#
#
#
sub _id {
    my($self) = @_;
    return $self->new_other('Class')
	->get_id_for_student($self->get_request->get('auth_id'))
	|| $self->get_instance('ClassSelectList')->EMPTY_KEY_VALUE;
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
