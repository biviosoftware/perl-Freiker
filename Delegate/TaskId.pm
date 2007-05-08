# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::TaskId;
use strict;
use base 'Bivio::Delegate::TaskId';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(@{$proto->ALL_INFO}, [
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
# 	[qw(
# 	    MY_CLUB_SITE
# 	    6
# 	    GENERAL
# 	    ANY_USER
# 	    Bivio::Auth::RealmType->execute_club
# 	    Action.ClientRedirect->execute_path_info
# 	)],
#501-502
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
	    View.School->register
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
	    View.UserAuth->create_mail
	    View.UserAuth->registration_sent
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
	    View.Family->register
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
	    View.UserAuth->create_mail
	    View.UserAuth->registration_sent
        )],
	[qw(
	    FAMILY_FREIKER_LIST
	    509
	    USER
	    ADMIN_READ
	    Model.FreikerList->execute_load_all_with_query
	    View.Family->freiker_list
	    MODEL_NOT_FOUND=FAMILY_FREIKER_ADD
	)],
	[qw(
	    FAMILY_FREIKER_ADD
	    510
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerForm
	    View.Family->freiker_add
	    next=FAMILY_FREIKER_LIST
	)],
	[qw(
	    FREIKOMETER_UPLOAD
	    511
	    GENERAL
	    ANYBODY
	    Action.BasicAuthorization
	    Action.FreikometerUpload
	)],
	[qw(
	    CLUB_FREIKER_LIST
	    512
	    CLUB
	    ADMIN_READ
	    Model.ClubFreikerList->execute_load_page
	    View.School->freiker_list
	)],
#513-517 free
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
	[qw(
	    FAMILY_FREIKER_RIDE_LIST
	    520
	    USER
	    ADMIN_READ
	    Model.FreikerRideList->execute_load_page
	    View.Family->freiker_ride_list
	)],
	[qw(
	    FAMILY_MANUAL_RIDE_FORM
	    521
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.ManualRideForm
	    View.Family->manual_ride_form
	    next=FAMILY_FREIKER_RIDE_LIST
	)],
	[qw(
	    FAMILY_FREIKER_CODE_ADD
	    522
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.FreikerCodeForm
	    View.Family->freiker_code_add
	    next=FAMILY_FREIKER_RIDE_LIST
	)],
    ]);
}

1;
