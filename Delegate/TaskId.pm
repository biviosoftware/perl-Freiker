# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::TaskId;
use strict;
use base 'Bivio::Delegate::SimpleTaskId';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(shift->SUPER::get_delegate_info(@_), [
	[qw(
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.HomeRedirect
	    wheel_task=CLUB_FREIKER_LIST
	    family_task=FAMILY_FREIKER_LIST
	    next=USER_REALMLESS_REDIRECT
	    FORBIDDEN=LOGIN
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
	    LOGOUT
	    502
	    GENERAL
	    ANYBODY
	    Action.UserLogout
            Action.ClientRedirect->execute_next
            next=MY_SITE
	)],
	[qw(
	    USER_REALMLESS_REDIRECT
	    503
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=SITE_ROOT
	    home_task=MY_SITE
	    unauth_task=SITE_ROOT
	)],
	[qw(
	    CLUB_REGISTER
	    504
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.ClubRegisterForm
	    View.club/register
	    next=FAMILY_REGISTER_DONE
	    reset_task=USER_PASSWORD_RESET
	    reset_next_task=GENERAL_USER_PASSWORD_QUERY_MAIL
	    cancel=SITE_ROOT
	)],
	[qw(
	    CLUB_REGISTER_DONE
	    505
	    GENERAL
	    ANYBODY
	    View.mail/registration
	    View.registration-sent
	)],
	[qw(
	    CLUB_REALMLESS_REDIRECT
	    506
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=CLUB_REGISTER
	    home_task=CLUB_FREIKER_LIST
	    unauth_task=SITE_ROOT
	)],
	[qw(
	    FAMILY_REGISTER
	    507
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserRegisterForm
	    View.family/register
	    next=FAMILY_REGISTER_DONE
	    reset_task=USER_PASSWORD_RESET
	    reset_next_task=GENERAL_USER_PASSWORD_QUERY_MAIL
	    cancel=SITE_ROOT
	)],
	[qw(
            FAMILY_REGISTER_DONE
            508
            GENERAL
	    ANYBODY
	    View.mail/registration
	    View.registration-sent
        )],
	[qw(
	    FAMILY_FREIKER_LIST
	    509
	    USER
	    ADMIN_READ
	    Model.FreikerList->execute_load_all_with_query
	    View.family/freiker-list
	    MODEL_NOT_FOUND=FAMILY_FREIKER_ADD
	)],
	[qw(
	    FAMILY_FREIKER_ADD
	    510
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerForm
	    View.family/freiker-add
	    next=FAMILY_FREIKER_LIST
	)],
	[qw(
	    FREIKOMETER_UPLOAD
	    511
	    CLUB
	    ANYBODY
	    Action.BasicAuthorization
	    Action.FreikometerUpload
	)],
	[qw(
	    CLUB_FREIKER_LIST
	    512
	    CLUB
	    ADMIN_READ
	    Model.ClubFreikerList->execute_load_all_with_query
	    View.club/freiker-list
	)],
	[qw(
	    SITE_SPONSORS
	    513
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain->execute_uri_as_view
        )],
	[qw(
	    SITE_PARENTS
	    514
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain->execute_uri_as_view
        )],
	[qw(
	    SITE_PRESS
	    515
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain->execute_uri_as_view
        )],
	[qw(
	    SITE_PRIZES
	    516
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain->execute_uri_as_view
        )],
	[qw(
	    SITE_WHEELS
	    517
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain->execute_uri_as_view
        )],
	[qw(
	    SITE_DONATE
	    518
	    GENERAL
	    ANYBODY
	    Model.PayPalForm
	    Action.LocalFilePlain->execute_uri_as_view
	    next=SITE_ROOT
        )],
	[qw(
	    PAYPAL_RETURN
	    519
	    GENERAL
	    ANYBODY
	    Action.PayPalReturn
        )],
    ]);
}

1;
