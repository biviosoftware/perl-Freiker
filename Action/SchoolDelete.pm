# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::SchoolDelete;
use strict;
$Freiker::Action::SchoolDelete::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Action::SchoolDelete::VERSION;

=head1 NAME

Freiker::Action::SchoolDelete - deletes school by zip

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Action::SchoolDelete;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Freiker::Action::SchoolDelete::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Freiker::Action::SchoolDelete>

=cut

#=IMPORTS
use Freiker::Test;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Always returns false.

=cut

sub execute {
    my($proto, $req) = @_;
    my($zip) = delete(($req->unsafe_get('query') || {})->{zip});
    my($a) = Bivio::Biz::Model->new($req, 'Address');
    return unless $zip && $a->unauth_load({
	zip => $zip,
    });
    Freiker::Test->delete_school($a->get('realm_id'), $req);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
