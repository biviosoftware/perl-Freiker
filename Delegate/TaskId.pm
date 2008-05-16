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
	    MERCHANT
	    ADMIN_READ&ADMIN_WRITE
	    Model.PrizeCouponRedeemForm
	    View.Merchant->prize_redeem
	    next=MERCHANT_PRIZE_RECEIPT
	)],
	[qw(
	    MERCHANT_HOME
	    503
	    MERCHANT
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    CLUB_REGISTER
	    504
	    GENERAL
	    ANY_USER
	    Model.ClubRegisterForm
	    View.Club->register
	    next=CLUB_FREIKER_LIST
	)],
	[qw(
	    MERCHANT_PRIZE_RECEIPT
	    505
	    MERCHANT
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
	    MERCHANT
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
	    ADM_FREIKOMETER_LIST
	    511
	    GENERAL
	    ADMIN_READ
	    Model.AdmFreikometerList->execute_load_page
	    View.Adm->freikometer_list
	)],
	[qw(
	    CLUB_FREIKER_LIST
	    512
	    CLUB
	    ADMIN_READ
	    Model.ClubFreikerList->execute_load_page
	    View.Club->freiker_list
	)],
	[qw(
	    FAMILY_PRIZE_SELECT
	    513
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.PrizeSelectList->execute_load_for_user_and_credit
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
	    MERCHANT
	    ADMIN_READ
	    Model.MerchantPrizeList->execute_load_all_with_query
	    View.Merchant->prize_list
	    MODEL_NOT_FOUND=MERCHANT_PRIZE
	)],
	[qw(
	    PAYPAL_FORM
	    518
	    FORUM
	    ANYBODY
	    Model.PayPalForm
	    View.Wiki->view
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
	    View.Club->prize_list
	)],
	[qw(
	    CLUB_PRIZE
	    524
	    CLUB
	    ADMIN_READ
	    Model.ClubPrizeList->execute_load_this
	    Model.ClubPrizeForm
	    View.Club->prize
	    next=CLUB_PRIZE_LIST
	)],
	[qw(
	    CLUB_RIDE_DATE_LIST
	    525
	    CLUB
	    ADMIN_READ
	    Model.ClubRideDateList->execute_load_page
	    View.Club->ride_date_list
	)],
	[qw(
	    BOT_FREIKOMETER_UPLOAD
	    526
	    GENERAL
	    ANYBODY
	    Action.FreikometerUpload
	    Action.FreikometerDownload->execute_redirect_next_get
	    Action.EmptyReply
	)],
	[qw(
	    BOT_FREIKOMETER_DOWNLOAD
	    527
	    USER
	    ADMIN_READ
	    Action.FreikometerDownload->execute_get
	)],
	[qw(
	    CLUB_FREIKER_CODE_IMPORT
	    528
	    CLUB
	    ADMIN_READ&ADMIN_WRITE&SUPER_USER_TRANSIENT
	    Model.FreikerCodeImportForm
	    View.Adm->freiker_code_import
	    next=CLUB_FREIKER_LIST
	)],
	[qw(
	    ALL_CLUB_SUMMARY_LIST
	    529
	    GENERAL
	    ANYBODY
	    Model.AllClubSummaryList->execute_load_all
	    View.WikiWidget->all_club_summary_list
	)],
	[qw(
	    MERCHANT_FILE
	    530
	    MERCHANT
	    ANYBODY
	    Action.RealmFile->access_controlled_execute
	)],
	[qw(
	    ADM_PRIZE_LIST
	    531
	    GENERAL
	    ADMIN_READ
	    Model.AdmPrizeList->execute_load_all_with_query
	    View.Adm->prize_list
	)],
	[qw(
	    ADM_PRIZE
	    532
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.AdmPrizeList->execute_load_this
	    Model.AdmPrizeForm
	    View.Adm->prize
	    next=ADM_PRIZE_LIST
	)],
	[qw(
	    CLUB_FREIKER_SELECT
	    533
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerSelectForm
	    View.Club->freiker_select
	    next=CLUB_FREIKER_PRIZE_SELECT
	)],
	[qw(
	    CLUB_FREIKER_PRIZE_SELECT
	    534
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.ClubPrizeSelectList->execute_load_for_user_and_credit
	    View.Club->prize_select
	    next=CLUB_FREIKER_PRIZE_CONFIRM
	)],
	[qw(
	    CLUB_FREIKER_PRIZE_CONFIRM
	    535
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.ClubPrizeConfirmForm
	    View.Club->prize_confirm
	    next=CLUB_FREIKER_PRIZE_SELECT
	    cancel=CLUB_FREIKER_SELECT
	)],
	[qw(
	    FAMILY_PRIZE_PICKUP
	    536
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerList->execute_load_this
	    Action.FamilyPrizePickup
	)],
	[qw(
	    ADM_PRIZE_COUPON_LIST
	    537
	    GENERAL
	    ADMIN_READ
	    Model.AdmPrizeCouponList->execute_load_page
	    View.Adm->prize_coupon_list
	)],
	[qw(
	    GENERAL_PRIZE_LIST
	    538
	    GENERAL
	    ANYBODY
	    Model.AvailablePrizeList->execute_load_all_with_query
	    View.General->prize_list
	)],
	[qw(
	    CLUB_FREIKER_MANUAL_RIDE_FORM
	    539
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.ClubManualRideForm
	    View.Club->manual_ride_form
	    next=CLUB_FREIKER_PRIZE_SELECT
	)],
    ]);
}

1;
