# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
$Freiker::Util::SQL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Util::SQL::VERSION;

=head1 NAME

Freiker::Util::SQL - ddl configuration

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Util::SQL;

=cut

=head1 EXTENDS

L<Bivio::Util::SQL>

=cut

use Bivio::Util::SQL;
@Freiker::Util::SQL::ISA = ('Bivio::Util::SQL');

=head1 DESCRIPTION

C<Freiker::Util::SQL> are utilities for initializing and managing the database.

How to create the database.  As root:

    su - postgres -c 'createuser --no-createdb --no-adduser --pwprompt fruser; createdb --owner fruser fr'

As you:

    cd files/ddl
    fr-sql create_db

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="ddl_files"></a>

=head2 ddl_files() : array_ref

Returns DDL SQL file names used to create/destroy database.

=cut

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'fr']);
}

=for html <a name="init_realm_role"></a>

=head2 init_realm_role()

Adds SCHOOL and CLASS realms, copies permissions from CLUB.

=cut

sub init_realm_role {
    my($self) = shift;
    my(@res) = $self->SUPER::init_realm_role(@_);
    map(
	$self->new_other('Bivio::Biz::Util::RealmRole')->copy_all(club => $_),
	qw(school class),
    );
    return @res;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;

