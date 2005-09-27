# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::HomeRedirect;
use strict;
$Freiker::Action::HomeRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Action::HomeRedirect::VERSION;

=head1 NAME

Freiker::Action::HomeRedirect - redirect to appropriate task

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Action::HomeRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Freiker::Action::HomeRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Freiker::Action::HomeRedirect>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Redirects to appropriate task.

=cut

sub execute {
    my($proto, $req) = @_;
    $req->set_realm($req->get('auth_user'));
    my($m) = Bivio::Biz::Model->new($req, 'UserRealmList')->load_all;
    return 'next'
	unless $m->find_row_by_type(Bivio::Auth::RealmType->SCHOOL);
    return 'freiker_task'
	if $m->get('RealmUser.role')->equals_by_name('FREIKER');
    $req->set_realm($m->get('RealmUser.realm_id'));
    return 'wheel_task';
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
