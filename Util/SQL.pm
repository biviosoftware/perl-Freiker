# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use base 'Bivio::Util::SQL';
use Bivio::Test::Language::HTTP;
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# su - postgres -c 'createuser --no-createdb --no-adduser --pwprompt fruser; createdb --owner fruser fr'

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'fr']);
}

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
	    'Email.email' => $self->format_test_email(Freiker::Test->WHEEL),
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
	    'Email.email' => $self->format_test_email(Freiker::Test->ADM),
	},
    );
    $self->new_other('Bivio::Biz::Util::RealmRole')->make_super_user;
    return;
}

1;
