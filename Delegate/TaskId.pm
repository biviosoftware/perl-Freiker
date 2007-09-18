# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::TaskId;
use strict;
use base 'Bivio::Delegate::TaskId';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(@{$proto->standard_components}, [
	[qw(
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.HomeRedirect
	    merchant_task=MERCHANT_PRIZE_LIST
	    wheel_task=CLUB_FREIKER_LIST
	    family_task=FAMILY_FREIKER_LIST
	    next=USER_REALMLESS_REDIRECT
	    FORBIDDEN=LOGIN
	)],
 	[qw(
 	    FORUM_WIKI_VIEW
 	    48
 	    FORUM
 	    ANYBODY
 	    Action.WikiView
	    View.Wiki->view
	    MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
	    edit_task=FORUM_WIKI_EDIT
	    want_author=1
 	)],
 	[qw(
 	    FORUM_FILE
 	    52
 	    FORUM
 	    ANYBODY
 	    Action.RealmFile->access_controlled_execute
        )],
#TODO: Blog

# 	[qw(
# 	    MY_CLUB_SITE
# 	    6
# 	    GENERAL
# 	    ANY_USER
# 	    Bivio::Auth::RealmType->execute_club
# 	    Action.ClientRedirect->execute_path_info
# 	)],
	[qw(
	    MERCHANT_REGISTER
	    501
	    GENERAL
	    ANY_USER
	    Model.MerchantInfoForm
	    View.Merchant->info
	    next=MERCHANT_PRIZE_REDEEM
	)],
	[qw(
	    MERCHANT_PRIZE_REDEEM
	    502
	    FORUM
	    ADMIN_READ&ADMIN_WRITE
	    Model.PrizeRedeemForm
	    View.Merchant->prize_redeem
	    next=MERCHANT_PRIZE_RECEIPT
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
	    ANY_USER
	    Model.ClubRegisterForm
	    View.School->register
	    next=CLUB_FREIKER_LIST
	)],
	[qw(
	    MERCHANT_PRIZE_RECEIPT
	    505
	    FORUM
	    ADMIN_READ
	    Model.PrizeReceipt
	    View.Merchant->prize_receipt
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
	    FORUM_REALMLESS_REDIRECT
	    507
	    GENERAL
	    ANYBODY
	    Action.RealmlessRedirect
	    visitor_task=MERCHANT_REGISTER
	    home_task=MERCHANT_PRIZE_REDEEM
	    unauth_task=SITE_ROOT
	)],
	[qw(
	    MERCHANT_PRIZE
	    508
	    FORUM
	    ADMIN_READ&ADMIN_WRITE
	    Model.MerchantPrizeForm
	    View.Merchant->prize
	    next=MERCHANT_PRIZE_LIST
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
	[qw(
	    FAMILY_PRIZE_SELECT
	    513
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.PrizeSelectList->execute_load_all_with_query
	    View.Family->prize_select
	    next=FAMILY_PRIZE_CONFIRM
	)],
	[qw(
	    FAMILY_PRIZE_CONFIRM
	    514
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.PrizeConfirmForm
	    View.Family->prize_confirm
	    next=FAMILY_PRIZE_COUPON
	)],
	[qw(
	    FAMILY_PRIZE_COUPON
	    515
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.PrizeCouponList->execute_load_this
	    View.Family->prize_coupon
	)],
	[qw(
	    FAMILY_PRIZE_COUPON_LIST
	    516
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerPrizeCouponList->execute_load_all_with_query
	    View.Family->prize_coupon_list
	)],
	[qw(
	    MERCHANT_PRIZE_LIST
	    517
	    FORUM
	    ADMIN_READ
	    Model.MerchantPrizeList->execute_load_all_with_query
	    View.Merchant->prize_list
	    MODEL_NOT_FOUND=MERCHANT_PRIZE_REDEEM
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
	[qw(
	    CLUB_PRIZE_LIST
	    523
	    CLUB
	    ADMIN_READ
	    Model.ClubPrizeList->execute_load_all
	    View.School->prize_list
	)],
	[qw(
	    CLUB_PRIZE
	    524
	    CLUB
	    ADMIN_READ
	    Model.ClubPrizeList->execute_load_this
	    Model.ClubPrizeForm
	    View.School->prize
	    next=CLUB_PRIZE_LIST
	)],
    ]);
}

1;
