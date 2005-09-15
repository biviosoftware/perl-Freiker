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
use Freiker::Test;

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
    $self->set_realm_and_user('club', 'user');
    my($rr) = $self->new_other('Bivio::Biz::Util::RealmRole');
    $rr->edit(WHEEL => '+ADMINISTRATOR');
    $rr->edit(TEACHER => '+ADMINISTRATOR');
    $rr->edit(FREIKER => '+MEMBER');
    $rr->edit(STUDENT => '+MEMBER');
    map(
	$rr->copy_all(club => $_),
	qw(school class),
    );
    $self->set_realm_and_user('school', 'user');
    # Teacher doesn't have admin privs in a school;  We don't
    # give teachers access to school anyway, because they don't
    # log in.  Just in case, though.
    $rr->edit(TEACHER => qw(- +MEMBER));
    return @res;
}

=for html <a name="initialize_test_data"></a>

=head2 initialize_test_data()

Initializes wheel and adm.

=cut

sub initialize_test_data {
    my($self) = @_;
    my($req) = $self->get_request;
    Bivio::Biz::Model->get_instance('SchoolRegisterForm')->execute(
	$req, {
	    school_name => Freiker::Test->SCHOOL,
	    zip => Freiker::Test->ZIP,
	    'RealmOwner.display_name' => Freiker::Test->WHEEL,
	    'RealmOwner.name' => Freiker::Test->WHEEL,
	    'RealmOwner.password' => Freiker::Test->PASSWORD,
	    'confirm_password' => Freiker::Test->PASSWORD,
	    'School.website' => Freiker::Test->WEBSITE,
	    'Email.email' => $req->format_email(Freiker::Test->WHEEL),
	},
    );
    Bivio::Biz::Model->new($req, 'Class')->create_realm({
	class_grade => Bivio::Type->get_instance('ClassGrade')->FIRST,
	class_size => 20,
    }, {
	first_name => 'Erste',
	last_name => 'Klasse',
	gender => Bivio::Type->get_instance('Gender')->MALE,
    });
    Bivio::Biz::Model->get_instance('UserCreateForm')->execute(
	$req, {
	    'RealmOwner.display_name' => Freiker::Test->ADM,
	    'RealmOwner.name' => Freiker::Test->ADM,
	    'RealmOwner.password' => Freiker::Test->PASSWORD,
	    'confirm_password' => Freiker::Test->PASSWORD,
	    'Email.email' => $req->format_email(Freiker::Test->ADM),
	},
    );
    $self->new_other('Bivio::Biz::Util::RealmRole')->make_super_user;
    return;
}

=for html <a name="internal_upgrade_db"></a>

=head2 internal_upgrade_db()

Change display_names which match names.

=cut

sub internal_upgrade_db {
    my($self) = @_;
    Bivio::Biz::Model->new($self->get_request, 'RealmOwner')->do_iterate(
	sub {
	    my($m) = @_;
	    $m->update({display_name => ' '})
		if !$m->is_default
		&& $m->get('name') eq $m->get('display_name');
	    return 1;
	},
	unauth_iterate_start => 'realm_id', {
	    realm_type => Bivio::Auth::RealmType->USER,
       },
    );
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;

