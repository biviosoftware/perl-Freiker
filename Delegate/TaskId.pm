# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Delegate::TaskId;
use strict;
$Freiker::Delegate::TaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Delegate::TaskId::VERSION;

=head1 NAME

Freiker::Delegate::TaskId - additional tasks

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Delegate::TaskId;

=cut

use Bivio::Delegate::SimpleTaskId;
@Freiker::Delegate::TaskId::ISA = ('Bivio::Delegate::SimpleTaskId');

=head1 DESCRIPTION

C<Freiker::Delegate::TaskId>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(shift->SUPER::get_delegate_info(@_), [
	[qw(
	    LOGIN
	    501
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    SCHOOL_REGISTER
	    502
	    GENERAL
	    ANYBODY
	    Model.SchoolRegisterForm
	    View.school-register
	    next=SITE_ROOT
	)],
	[qw(
	    SCHOOL_HOME
	    503
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
