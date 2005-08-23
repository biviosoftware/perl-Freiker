# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Delegate::FormErrors;
use strict;
$Freiker::Delegate::FormErrors::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Delegate::FormErrors::VERSION;

=head1 NAME

Freiker::Delegate::FormErrors - additional type errors

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Delegate::FormErrors;

=cut

use Bivio::Delegate::SimpleFormErrors;
@Freiker::Delegate::FormErrors::ISA = ('Bivio::Delegate::SimpleFormErrors');

=head1 DESCRIPTION

C<Freiker::Delegate::FormErrors>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : string_ref

Returns the form error definitions.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return \(<<'EOF' . ${shift->SUPER::get_delegate_info(@_)});
UserLoginForm
RealmOwner.password
PASSWORD_MISMATCH
The password you entered does not match the value stored
in our database.
Please remember that passwords are case-sensitive, i.e.
"HELLO" is not the same as "hello".
%%
EOF
};

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
