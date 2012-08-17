# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Delegate::TaskId;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(@{$proto->standard_components}, [
	{
	    name => 'LOGOUT',
	    next => b_use('IO.Config')->is_production
		? b_use('Action.ClientRedirect')
		    ->uri_parameters('http://www.boltage.org')
		: 'SITE_ROOT',
	},
	{
	    name => 'GENERAL_CONTACT',
	    items => [qw(
		Model.SchoolContactList->execute_load_all
		Model.ContactForm
		View.UserAuth->general_contact
	    )],
	},
	[qw(
	    CLUB_HOME
	    7
	    CLUB
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=CLUB_RIDE_DATE_LIST
	)],
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
	    next=MERCHANT_PRIZE_LIST
	)],
	[qw(
	    CLUB_REGISTER
	    504
	    GENERAL
	    ANY_USER
	    Type.FormMode->execute_create
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
	    Model.FreikerListQueryForm
	    Model.FreikerList->execute_load_all_with_query
	    Action.ValidateAddress
	    View.Family->freiker_list
	    next=FAMILY_FREIKER_LIST
	    MODEL_NOT_FOUND=FAMILY_FREIKER_ADD
	)],
	[qw(
	    FAMILY_FREIKER_ADD
	    510
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerCodeForm
	    View.Freiker->code_form
	    next=FAMILY_FREIKER_RIDE_LIST
	    cancel=FAMILY_FREIKER_LIST
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
	    Model.FreikerListQueryForm
	    Model.ClubFreikerList->execute_load_page
	    Action.ValidateAddress
	    View.Club->freiker_list
	    next=CLUB_FREIKER_LIST
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
	    View.Freiker->ride_list
	)],
	[qw(
	    FAMILY_MANUAL_RIDE_FORM
	    521
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.ManualRideForm
	    View.Freiker->manual_ride_form
	    next=FAMILY_FREIKER_RIDE_LIST
	)],
	[qw(
	    FAMILY_FREIKER_CODE_ADD
	    522
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.FreikerCodeForm
	    View.Freiker->code_form
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
	    want_basic_authorization=1
	)],
	[qw(
	    BOT_FREIKOMETER_DOWNLOAD
	    527
	    USER
	    ADMIN_READ
	    Action.FreikometerDownload->execute_get
	    want_basic_authorization=1
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
	    Model.FreikerListQueryForm
	    Model.AllClubSummaryList->execute_load_all_with_query
	    View.WikiWidget->all_club_summary_list
	    next=ALL_CLUB_SUMMARY_LIST
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
	[qw(
	    CLUB_PRIZE_COUPON_LIST
	    540
	    CLUB
	    ADMIN_READ
	    Model.ClubPrizeCouponList->execute_load_page
	    View.Club->prize_coupon_list
	)],
	[qw(
	    GREEN_GEAR_FORM
	    541
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE
	    Model.GreenGearForm
	    View.GreenGear->form
	    next=GREEN_GEAR_LIST
	)],
	[qw(
	    GREEN_GEAR_LIST
	    542
	    ANY_OWNER
	    ADMIN_READ
	    Model.GreenGearList->execute_load_page
	    View.GreenGear->list
	)],
	[qw(
	    CLUB_RIDE_FILL_FORM
	    543
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE
	    Model.ClubRideFillForm
	    View.Club->ride_fill_form
	    next=CLUB_RIDE_DATE_LIST
	)],
	[qw(
	    CLUB_FREIKER_LIST_CSV
	    544
	    CLUB
	    ADMIN_READ
	    Model.FreikerListQueryForm
	    Model.ClubFreikerList->execute_load_all
	    View.Club->freiker_list_csv
	    next=CLUB_FREIKER_LIST_CSV
	)],
	[qw(
	    CLUB_FREIKER_PRIZE_DELETE
	    545
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.ClubPrizeDeleteForm
	    View.Club->prize_delete
	    next=CLUB_PRIZE_COUPON_LIST
	)],
	[qw(
	    BOT_ZAP_UPLOAD
	    546
	    GENERAL
	    ANYBODY
	    Action.FreikometerUpload->execute_zap
	    Action.EmptyReply
	)],
	[qw(
	    USER_ACCEPT_TERMS_FORM
	    547
	    GENERAL
	    ANY_USER
	    Model.AcceptTermsForm
	    Action.WikiView->bp_Accept_Terms
	    next=MY_SITE
	)],
	[qw(
	    FAMILY_FREIKER_EDIT
	    548
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.FreikerForm
	    View.Freiker->form
	    next=FAMILY_FREIKER_LIST
	)],
	[qw(
	    CLUB_FREIKER_ADD
	    549
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerCodeForm
	    View.Freiker->code_form
	    next=CLUB_FREIKER_RIDE_LIST
	    cancel=CLUB_FREIKER_LIST
	)],
	[qw(
	    CLUB_FREIKER_EDIT
	    550
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.FreikerForm
	    View.Freiker->form
	    next=CLUB_FREIKER_LIST
	)],
	[qw(
	    CLUB_FREIKER_RIDE_LIST
	    551
	    CLUB
	    ADMIN_READ
	    Model.FreikerRideList->execute_load_page
	    View.Freiker->ride_list
	)],
	[qw(
	    CLUB_MANUAL_RIDE_FORM
	    552
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.ManualRideForm
	    View.Freiker->manual_ride_form
	    next=CLUB_FREIKER_RIDE_LIST
	)],
	[qw(
	    CLUB_FREIKER_CODE_ADD
	    553
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.FreikerRideList->execute_load_all_with_query
	    Model.FreikerCodeForm
	    View.Freiker->code_form
	    next=CLUB_FREIKER_RIDE_LIST
	)],
	[qw(
	    SCHOOL_CLASS_HOME
	    554
	    SCHOOL_CLASS
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    CLUB_SCHOOL_CLASS_LIST_FORM
	    555
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.Lock
	    Model.SchoolClassListForm
	    View.Club->school_class_list_form
	    next=CLUB_FREIKER_LIST
	)],
	[qw(
	    CLUB_FREIKER_IMPORT_EMPTY_CSV
	    556
	    CLUB
	    ADMIN_READ
	    Model.FreikerImportForm->execute_empty_csv
	    next=CLUB_FREIKER_IMPORT_EMPTY_CSV
	)],
	[qw(
	    CLUB_FREIKER_IMPORT_FORM
	    557
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.Lock
	    Model.FreikerImportForm
	    View.Club->freiker_import_form
	    next=CLUB_FREIKER_LIST
	)],
	[qw(
	    CLUB_FREIKER_CLASS_LIST_FORM
	    558
	    CLUB
	    ADMIN_READ
	    Model.ClubFreikerList->execute_load_page
	    Model.ClubFreikerClassListForm
	    View.Club->freiker_class_list_form
	    next=CLUB_FREIKER_CLASS_LIST_FORM
	)],
	[qw(
	    CLUB_FREIKER_CLASS_LIST
	    559
	    CLUB
	    ADMIN_READ
	    Model.FreikerListQueryForm
	    Model.ClubFreikerClassList->execute_load_page
	    View.Club->freiker_class_list
	    next=CLUB_FREIKER_CLASS_LIST
	)],
	[qw(
	    ADM_SUMMARY_BY_SCHOOL_LIST
	    560
	    GENERAL
	    ADMIN_READ
	    Model.FreikerListQueryForm
	    Model.AdmSummaryBySchoolList->execute_load_all
	    View.Adm->summary_by_school_list
	    next=ADM_SUMMARY_BY_SCHOOL_LIST
	)],
	[qw(
	    CLUB_SUMMARY_BY_CLASS_LIST
	    561
	    CLUB
	    ADMIN_READ
	    Model.FreikerListQueryForm
	    Model.ClubSummaryByClassList->execute_load_all
	    View.Club->summary_by_class_list
	    next=ADM_SUMMARY_BY_SCHOOL_LIST
	)],
	[qw(
	    GROUP_USER_BULLETIN_LIST_CSV
	    562
	    ANY_OWNER
	    ADMIN_READ&FEATURE_GROUP_ADMIN
	    View.GroupAdmin->user_bulletin_list_csv
            require_secure=1
	)],
	[qw(
	    CLUB_MANUAL_RIDE_LIST_FORM
	    563
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Model.ManualRideList->execute_load_all_with_query
	    Model.ManualRideListForm
	    View.Freiker->manual_ride_list_form
	    next=CLUB_FREIKER_RIDE_LIST
	)],
	[qw(
	    FAMILY_MANUAL_RIDE_LIST_FORM
	    564
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.ManualRideList->execute_load_all_with_query
	    Model.ManualRideListForm
	    View.Freiker->manual_ride_list_form
	    next=FAMILY_FREIKER_RIDE_LIST
	)],
	[qw(
	    CLUB_PROFILE_FORM
	    565
	    CLUB
	    ADMIN_READ&ADMIN_WRITE
	    Action.Auth->execute_is_sub_or_super_user
	    Type.FormMode->execute_edit
	    Model.Address->execute_load
	    Model.SchoolContact->execute_load
	    Model.Website->execute_load
	    Model.ClubRegisterForm
	    View.Club->register
	    next=MY_SITE
        )],
	[qw(
	    ADM_FREIKER_CODE_REALLOCATE_FORM
	    566
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.ClubList->execute_load_all
	    Model.AdmFreikerCodeReallocateForm
	    View.Adm->freiker_code_reallocate_form
	    next=MY_SITE
        )],
	[qw(
	    ADM_FREIKER_CODE_REALLOCATE_CONFIRM
	    567
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.AdmFreikerCodeReallocateConfirmationForm
	    View.Adm->freiker_code_reallocate_confirm
	    next=MY_SITE
        )],
	[qw(
	    BOT_HUB_UPLOAD
	    568
	    GENERAL
	    ANYBODY
	    Action.FreikometerUpload->execute_hub
	    Action.EmptyReply
	    want_basic_authorization=1
	)],
    ]);
}

1;
