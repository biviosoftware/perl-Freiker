# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Test;
use strict;
$Freiker::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Test::VERSION;

=head1 NAME

Freiker::Test - common routines

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Test;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test;
@Freiker::Test::ISA = ('Bivio::Test');

=head1 DESCRIPTION

C<Freiker::Test>

=cut

#=IMPORTS
use Bivio::Test::Request;
use Bivio::Util::RealmAdmin;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="delete_all_schools"></a>

=head2 static delete_all_schools() : Bivio::Agent::Request

Deletes all schools and B<COMMITs>

=cut

sub delete_all_schools {
    my($proto) = @_;
    my($req) = Bivio::Test::Request->get_instance;
    Bivio::Biz::Model->new($req, 'RealmOwner')->map_iterate(
	sub {
	    my($m) = @_;
	    Freiker::Test->delete_school($m->get('realm_id'), $req)
		    unless $m->is_default;
	    return 1;
	},
	unauth_iterate_start =>
	    'name desc',
	{
	    realm_type => Bivio::Auth::RealmType->SCHOOL},
    );
    Bivio::SQL::Connection->commit;
    return $req;
}

=for html <a name="delete_school"></a>

=head2 static delete_school(string school_id, Bivio::Agent::Request req)

Deletes school and sets current realm to general.

=cut

sub delete_school {
    my(undef, $school_id, $req) = @_;
    $req->set_realm($school_id);
    foreach my $r (
	@{Bivio::Biz::Model->new($req, 'Class')->map_iterate(
	    sub {shift->get('class_id')},
	    unauth_iterate_start => 'class_id', {school_id => $school_id},
	)},
	$school_id,
    ) {
	$req->set_realm($r);
	Bivio::Util::RealmAdmin->delete_with_users;
    }
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
