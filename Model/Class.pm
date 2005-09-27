# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::Class;
use strict;
$Freiker::Model::Class::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::Class::VERSION;

=head1 NAME

Freiker::Model::Class - class

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::Class;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Freiker::Model::Class::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Freiker::Model::Class>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_realm"></a>

=head2 create_realm(hash_ref class, hash_ref teacher) : self

Creates the Class, User (Teacher) and RealmOwner models.
Must be operating in the School's realm.

B<Does not set the realm.>

=cut

sub create_realm {
    my($self, $class, $teacher) = @_;
    Bivio::Die->die('need to set dates properly in 2006')
	if Bivio::Type::DateTime->now_as_year >= 2006;
    $self->new_other('RealmOwner')->create({
	realm_type => Bivio::Auth::RealmType->CLASS,
	realm_id => $self->create({
	    %$class,
	    school_year => Bivio::Type::DateTime->now_as_year,
	    school_id => $self->get_request->get('auth_id'),
	})->get('class_id'),
    });
    $self->new_other('RealmUser')->create({
	realm_id => $self->get('class_id'),
        role => Bivio::Auth::Role->TEACHER,
	user_id => ($self->new_other('User')->create_realm($teacher))[0]
	    ->get('user_id'),
    });
    return $self;
}

=for html <a name="get_id_for_student"></a>

=head2 get_id_for_student(string user_id) : string

Returns class_id for this student or undef.

=cut

sub get_id_for_student {
    my($self, $user_id) = @_;
    my($r) = $self->new_other('RealmUser');
    return $r->unauth_load({
	user_id => $user_id,
	role => Bivio::Auth::Role->STUDENT,
    }) ? $r->get('realm_id') : undef;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    return {
        version => 1,
	table_name => 'class_t',
	columns => {
            class_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    school_id => ['School.school_id', 'NOT_NULL'],
	    class_grade => ['ClassGrade', 'NOT_ZERO_ENUM'],
	    class_size => ['ClassSize', 'NOT_NULL'],
	    school_year => ['Year', 'NOT_NULL'],
	},
	auth_id => 'class_id',
    };
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
