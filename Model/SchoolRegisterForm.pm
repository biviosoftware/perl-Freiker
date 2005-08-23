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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    'RealmOwner_2.display_name',
	    {
		name => 'Address.zip',
		constraint => 'NOT_NULL',
	    },
	    'School.website',
	],
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
