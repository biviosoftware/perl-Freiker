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
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.HomeRedirect
	    wheel_task=WHEEL_BARCODE_UPLOAD
	    freiker_task=FREIKER_RIDE_LIST
	    next=USER_REALMLESS_REDIRECT
	    FORBIDDEN=FREIKER_LOGIN
	)],
	[qw(
	    LOGIN
	    501
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserLoginForm
            View.login
	    next=MY_SITE
	)],
	[qw(
	    SCHOOL_REGISTER
	    502
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.Lock
	    Model.SchoolRegisterForm
	    View.school-register
	    next=WHEEL_CLASS_LIST
	)],
	[qw(
	    SCHOOL_HOME
	    503
	    SCHOOL
	    ANYBODY
            Action.ClientRedirect->execute_next
            next=WHEEL_CLASS_LIST
	)],
	[qw(
	    TEST_SCHOOL_DELETE
	    504
	    GENERAL
	    TEST_TRANSIENT
	    Action.SchoolDelete
            Action.ClientRedirect->execute_next
            next=SCHOOL_REGISTER
	)],
	[qw(
	    WHEEL_CLASS_LIST
	    505
	    SCHOOL
	    ADMIN_READ&ADMIN_WRITE
	    Model.Lock
	    Model.ClassList->execute_load_all_with_query
	    Model.ClassListForm
	    View.wheel/class-list
	    next=WHEEL_CLASS_LIST
	)],
	[qw(
	    CLASS_HOME
	    506
	    CLASS
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    LOGOUT
	    507
	    GENERAL
	    ANYBODY
	    Action.UserLogout
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    SCHOOL_REALMLESS_REDIRECT
	    508
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=SCHOOL_REGISTER
	    home_task=WHEEL_CLASS_LIST
	    unauth_task=SITE_ROOT
	)],
	[qw(
	    WHEEL_BARCODE_UPLOAD
	    509
	    SCHOOL
	    ADMIN_READ&ADMIN_WRITE
	    Model.Lock
	    Model.BarcodeUploadForm
	    View.wheel/barcode-upload
	    next=WHEEL_FREIKER_RANK_LIST
	)],
	[qw(
	    WHEEL_BARCODE_LIST
	    510
	    SCHOOL
	    ADMIN_READ&ADMIN_WRITE
	    Model.Lock
	    Model.ClassSelectList->execute_load_all
	    Model.BarcodeList->execute_load_all_with_query
	    Model.BarcodeListForm
	    View.wheel/barcode-list
	    next=WHEEL_FREIKER_RANK_LIST
	)],
	[qw(
	    SCHOOL_RANK_LIST
	    511
	    GENERAL
	    ANYBODY
	    Model.SchoolRankList->execute_load_all_with_query
	    View.school-rank-list
	)],
	[qw(
	    WHEEL_FREIKER_RANK_LIST
	    512
	    SCHOOL
	    ADMIN_READ
	    Model.FreikerRankList->execute_load_all_with_query
	    View.wheel/freiker-rank-list
	)],
	[qw(
	    USER_PASSWORD
	    513
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserPasswordForm
	    View.user-password
	    next=MY_SITE
	)],
	[qw(
	    USER_REALMLESS_REDIRECT
	    514
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=SITE_ROOT
	    home_task=MY_SITE
	    unauth_task=SITE_ROOT
	)],
	[qw(
            FREIKER_LOGIN
	    515
            GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.FreikerLoginForm
	    View.freiker/login
	    next=FREIKER_RIDE_LIST
	    info_task=FREIKER_INFO
	)],
	[qw(
            FREIKER_RIDE_LIST
	    516
            USER
	    DATA_READ
	    Model.FreikerRideList->execute_load_all
	    View.freiker/ride-list
	    FORBIDDEN=FREIKER_LOGIN
	)],
	[qw(
            FREIKER_INFO
	    517
            USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerInfoForm
	    View.freiker/info
	    FORBIDDEN=FREIKER_LOGIN
	    next=FREIKER_RIDE_LIST
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
