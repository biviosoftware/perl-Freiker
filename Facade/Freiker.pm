# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Facade::Freiker;
use strict;
use base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub SITE_ADM_REALM_NAME {
    return 'site-contact';
}

my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    uri => 'freiker',
    http_host => 'www.freiker.org',
    mail_host => 'freiker.org',
    Color => [
	[footer_border_top => 0x0],
	[[qw(a_link left_login_background notice h3 prize_img_border nav left_nav_background)] => 0x33aa33],
	[[qw(acknowledgement_border a_hover a_hover_img_border)] => 0x41d941],
	[[qw(title topic footer_border_top footer_tag_line)] => 0x666666],
	[[qw(err warn empty_list_border)] => 0xcc0000],
	[[qw(left_nav_a_hover main_left_text a_img_border prizes_background)] => 0xFFFFFF],
	[select_prize => 0xffcf06],
    ],
    Font => [
	[a_link => 'normal'],
	[a_hover => 'underline'],
	[body => ['family=Arial', 'small']],
	[highlight => 'bold'],
	[pending_upload => ['italic', 'uppercase']],
	[footer => []],
	[[qw(topic nav)] => [qw(140% bold)]],
	[left_nav_a_hover => []],
	[[qw(user_state dock)] => [qw(140% bold nowrap)]],
	[prize_name => 'bold'],
	[footer_tag_line => [qw(100% bold)]],
	[select_prize => [qw(bold underline)]],
    ],
    FormError => [
	[NUMBER => 'Please enter a number'],
	['PrizeCoupon.coupon_code.NOT_FOUND' => q{The vs_fe(q{label}); is not valid.  Please verify the number carefully.  If you already did this, please have the Freiker's parent contact us at vs_gears_email();.}],
	['PayPalForm.amount.NULL' => 'Any amount will do!'],
	['FreikerCode.freiker_code' => [
	    NOT_FOUND => q{This is not a valid vs_fe('label'); for your school.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.},
	    EXISTS => q{The vs_fe('label'); is already assigned to a Freiker.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.If(['->is_substitute_user'], SPAN_sui(' To force the assignment, resubmit the form.'));},
	    MUTUALLY_EXCLUSIVE => q{The vs_fe(q{label}); was scanned on vs_fe(q{detail}); when your child also rode with his old vs_fe(q{label});.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.If(['->is_substitute_user'], SPAN_sui(' To force the assignment, resubmit the form.'));},
	]],
	['ClubRegisterForm.Website.url.EXISTS' => q{This school's website is already registered.  Please try to find the "wheel" at your school.}],
	['ClubRegisterForm.club_name.EXISTS' => q{Your school is already registered.  Please try to find the "wheel" at your school.}],
	['email.EXISTS' => q{This email is already registered with vs_site_name();.  Link('Click here to login.', 'LOGIN', {no_context => 1});}],
	['Ride.ride_date.NOT_FOUND' => q{This date was not a school day. Or, the Freikometer did not send the rides to freiker.org (yet).  The Freikometer stores the rides until it can get a network connection.  Sometimes the network is down for days.}],
	['Ride.ride_date.DATE_RANGE' => q{This date was not a school day. Or, the Freikometer did not send the rides to freiker.org (yet).  The Freikometer stores the rides until it can get a network connection.  Sometimes the network is down for days.}],
	['Ride.ride_date.EXISTS' => q{The Freiker was already credited for this date.  Please enter a different date.}],
	[US_ZIP_CODE => q{The vs_fe(q{label}); must be 9-digit US Zip code.}],
	['PrizeConformForm.Prize.name.TOO_FEW' => q{You do not have enough available rides to chose this prize}],
	['UserLoginForm.login.OFFLINE_USER' => q{Not a registered Freiker Code.  Link('Please click on this link to register.', 'USER_CREATE');}],
	['AdmSubstituteUserForm.login.OFFLINE_USER' => q{Freiker Code not registered.  User must register before you can act as user.}],
	['FreikerSelectForm.FreikerCode.freiker_code.NOT_FOUND' => q{Freiker Code is not in our database.}],
	['FreikerSelectForm.FreikerCode.freiker_code.PERMISSION_DENIED' => q{Freiker is not at this school.}],
    ],
    Constant => [
	[xlink_paypal => {
	    uri => 'http://www.paypal.com/us',
	}],
	[my_site_redirect_map => [
	    [qw(GENERAL ADMINISTRATOR ADM_FREIKOMETER_LIST)],
	    [qw(MERCHANT ADMINISTRATOR MERCHANT_PRIZE_REDEEM)],
	    [qw(CLUB ADMINISTRATOR CLUB_FREIKER_LIST)],
	    [qw(USER ADMINISTRATOR FAMILY_FREIKER_LIST)],
	]],
	[ThreePartPage_want_SearchForm => 0],
    ],
    Task => [
	[ADM_FREIKOMETER_LIST => 'adm/freikometers'],
	[ALL_CLUB_SUMMARY_LIST => 'pub/ride-summary'],
	[BOT_FREIKOMETER_DOWNLOAD => '?/fm-down/*'],
	[BOT_FREIKOMETER_UPLOAD => '/fm/*'],
	[CLUB_FREIKER_LIST => '?/freikers'],
	[CLUB_FREIKER_MANUAL_RIDE_FORM => '?/give-rides'],
	[CLUB_PRIZE => '?/prize'],
	[CLUB_PRIZE_LIST => '?/prizes'],
	[CLUB_PRIZE_COUPON_LIST => '?/prize-coupons'],
	[ADM_PRIZE_LIST => 'adm/prizes'],
	[ADM_PRIZE_COUPON_LIST => 'adm/prize-coupons'],
	[ADM_PRIZE => 'adm/prize'],
	[CLUB_REGISTER => '/pub/register-school'],
	[CLUB_RIDE_DATE_LIST => '?/ride-dates'],
	[CLUB_FREIKER_CODE_IMPORT => '?/import-codes'],
	[CLUB_FREIKER_SELECT => '?/select-freiker'],
	[CLUB_FREIKER_PRIZE_SELECT => '?/select-prize'],
	[CLUB_FREIKER_PRIZE_CONFIRM => '?/confirm-prize'],
	[FAMILY_FREIKER_ADD => '?/register-freiker'],
	[FAMILY_FREIKER_CODE_ADD => '?/add-tag'],
	[FAMILY_FREIKER_LIST => '?/freikers'],
	[FAMILY_FREIKER_RIDE_LIST => '?/rides'],
	[FAMILY_MANUAL_RIDE_FORM => '?/add-ride'],
	[FAMILY_PRIZE_CONFIRM => '?/confirm-prize'],
	[FAMILY_PRIZE_COUPON => '?/prize-coupon'],
	[FAMILY_PRIZE_COUPON_LIST => '?/prize-coupons'],
	[FAMILY_PRIZE_SELECT => '?/select-prize'],
	[FAMILY_PRIZE_PICKUP => '?/pickup-prize'],
	[FAVICON_ICO => '/favicon.ico'],
	[LOCAL_FILE_PLAIN => ['i/*', 'f/*', 'h/*', 'm/*']],
	[MERCHANT_PRIZE => '?/prize'],
	[MERCHANT_PRIZE_LIST => '?/prizes'],
	[MERCHANT_PRIZE_RECEIPT => '?/prize-receipt'],
	[MERCHANT_PRIZE_REDEEM => '?/redeem-coupon'],
	[MERCHANT_PRIZE_REDEEM => '?/redeem-prize'],
	[MERCHANT_REGISTER => '/pub/register-merchant'],
	[MERCHANT_FILE => '?/file/*'],
	[PAYPAL_FORM => ['?/donate']],
	[PAYPAL_RETURN => 'pp/*'],
	[GENERAL_PRIZE_LIST => 'pub/prizes'],
    ],
    Text => [
	[support_email => 'gears'],
	[contact_email => 'gears'],
#TODO:	    [support_phone => '(800) 555-1212'],
	[site_name => q{Freiker}],
	[site_copyright => q{Freiker, Inc.}],
	[home_page_uri => '/bp/Home'],
	[Image_alt => [
	    at => 'at sign image to help avoid spam',
	    bivio_power => 'Operated by bivio Software, Inc.',
	    [qw(smiley smiley_80)] => 'Freiker: The Frequent Biker Program',
	]],
	[['email', 'login'] => 'Your Email'],
	[club_name => 'Official Name'],
	[freiker_code => q{Freiker ID}],
	[club_id => q{School}],
	[ride_count => 'Rides'],
	[prize_debit => 'Spent'],
	[prize_credit => 'Credits'],
	[freiker_codes => 'Tag ID(s)'],
	[Ride => [
	    ride_date => 'Date',
	]],
	['WikiView.start_page' => 'Home'],
	['Address.zip.desc' =>
	     q{A 9-digit US zip code is required.  Link('Look it up at the USPS.', 'http://zip4.usps.com/zip4/welcome.jsp', {link_target => '_blank'});},
        ],
	[ClubRegisterForm => [
	    'club_size' => 'Number of Students',
	    'club_size.desc' => 'Total number of students including freikers and non-freikers.',
	    'Website.url' => 'School Website',
	    'Website.url.desc' => 'Example: http://schools.bvsd.org/crestview/index.html',
	    'Address.zip' => 'US ZIP+4',
	    ok_button => 'Register school',
	]],
	[MerchantInfoForm => [
	    prose => [
		prologue => q{vs_site_name(); uses local merchants as distribution points for prizes.  You may also donate prizes and manage the prize descriptions through this website.  Once you are registered, we'll contact you about prize logistics and fees.},
            ],
	    'RealmOwner.display_name' => 'Business Name',
	    'Website.url' => 'Business Website',
	    'Address.zip' => 'US ZIP+4',
	    ok_button => 'Register merchant',
	]],
	[Prize => [
	    name => 'Title',
	    description => 'Description',
	    retail_price => 'Retail Price',
	    detail_uri => 'Info Link',
	    prize_status => 'Status',
	    modified_date_time => 'Last Updated',
	]],
	[[qw(PrizeRideCount Prize)] => [
	    ride_count => 'Required Rides',
	]],
	[[qw(AdmPrizeCouponList ClubPrizeCouponList)] => [
	    'PrizeCoupon.creation_date_time' => 'Delivered',
	    'Prize.name' => 'Prize',
	    'RealmOwner.display_name' => 'Freiker',
	    family_display_name => 'Parent',
	]],
	[[qw(MerchantPrizeForm AdmPrizeForm)] => [
	    image_file => 'Image',
	    ok_button => 'OK',
	]],
	[AdmSubstituteUserForm => [
	    login => 'Email or Code',
	]],
	[UserLoginForm => [
	    prose => [
		prologue => q{vs_text_as_prose('USER_CREATE');},
		epilogue => q{vs_text_as_prose('GENERAL_USER_PASSWORD_QUERY');},
	    ],
	]],
	[Prize => [
	    name => 'Name',
	]],
	[[qw(PrizeCoupon PrizeReceipt)] => [
	    coupon_code => 'Coupon ID',
	]],
	[PrizeReceipt => [
	    receipt_code => 'Authorization Code',
	]],
	[PrizeCouponRedeemForm => [
	    prose => [
		prologue => q{Please enter the Freiker's vs_text_as_prose('PrizeReceipt.coupon_code');.},
	    ],
	    ok_button => 'Redeem',
	]],
	[PrizeRideCount => [
	    ride_count => 'Ride Count',
	]],
	[UserRegisterForm => [
	    prose => [
		prologue => q{In order to better serve you, we validate all email addresses.  When you click Register, we'll email a link which will you to set your password.},
		epilogue => q{vs_text_as_prose('LOGIN');},
	    ],
	    'Email.email.desc' =>
		q{We only send emails related to vs_site_name();.},
	    'RealmOwner.display_name' => 'Your Name',
	    'RealmOwner.display_name.desc' => q{Your first and last name, not your business or school's name.},
	    'Address.zip' => 'Your ZIP+4 Code',
	    ok_button => 'Register',
	]],
	[FreikerForm => [
	    'User.first_name' => q{First Name},
	    'User.first_name.desc' => q{This is for your information only so it may be a nickname, an abbreviation, or any other identifier.},
	    'FreikerCode.freiker_code.desc' => q{The number on your child's helmet or backpack.},
	    'birth_year' => q{Year of Birth},
	    'User.gender' => q{Gender},
	    ok_button => 'Register child',
	]],
	[FreikerCodeForm => [
	    prose => [
		prologue => q{Enter the new Freiker ID from the tag on your child's helmet or backpack.  If the tag is missing from your child's helmet or backpack, or you need another tag for a new helmet or backpack, vs_wheel_contact();.},
	    ],
	    ok_button => 'Add tag',
	]],
	[ClubManualRideForm => [
	    add_days => 'Number of Days',
	    ok_button => 'Give rides',
	]],
	[ManualRideForm => [
	    'Ride.ride_date' => q{Date Missing},
	    ok_button => 'Add ride',
	    prose => [
		prologue => <<'EOF',
We allow a certain number of missed rides as a courtesy to parents.
When there are too many missed rides, this list will no longer show.
Please enter the date of the missing ride for
String([qw(Model.FreikerRideList ->get_display_name)]);.
EOF
	    ],
	]],
	[AdmFreikometerList => [
	    'RealmOwner.name' => 'Freikometer',
	    'RealmFile.modified_date_time' => 'Last Upload',
	]],
	[separator => [
	    optional => 'Optional information used for statistical purposes',
	]],
	[[qw(FreikerList ClubFreikerList)] => [
	    'RealmOwner.display_name' => 'Freiker',
	    empty_list_prose => 'No Freikers as yet.',
	    list_actions => 'Actions',
	]],
	[PayPalForm => [
	    amount => '$',
	    ok_button => 'Donate Securely via PayPal',
	]],
	[ContactForm => [
	    from => 'Your Email',
	    text => 'Message',
	    ok_button => 'Send',
	]],
	[FreikerCodeImportForm => [
	    source => 'CSV File',
	    ok_button => 'Import',
	]],
	[ClubPrizeConfirmForm => [
	    ok_button => 'Deliver Prize',
	]],
	[AllClubSummaryList => [
	    'RealmOwner.display_name' => 'School',
	    days_1 => 'Day',
	    days_5 => 'Week',
	    days_20 => 'Month',
	]],
	[UserPasswordQueryForm => [
	    'prose.prologue' => q{P_prose('Please enter the email address you used to register and click Send.  You will receive an email with a link to reset your password.');},
	    ok_button => 'Send',
	]],
	[prose => [
	    wiki_by_line => '',
	    LOGIN => q{Already registered?  Link('Click here to login.', {task_id => 'LOGIN', no_context => 1});},
	    USER_CREATE => q{Child not registered?  vs_link('Click here to register.', 'USER_CREATE');},
	    CLUB_REGISTER => q{Would you like to become a wheel? vs_link('Click here to register your school.', 'CLUB_REGISTER');},
	    MERCHANT_REGISTER => q{Are you a merchant? vs_link('Click here to register your business.', 'MERCHANT_REGISTER');},
	    GENERAL_USER_PASSWORD_QUERY => q{Forgot your password? Link('Click here to get a new one.', 'GENERAL_USER_PASSWORD_QUERY');},
	]],
	[acknowledgement => [
	    CLUB_REGISTER => q{Your school has been registered.},
	    MERCHANT_REGISTER => q{Your business has been registered.},
	    FAMILY_FREIKER_ADD => q{Your child has been added.},
	    FAMILY_MANUAL_RIDE_FORM => q{The missing date has been added.},
	    FAMILY_FREIKER_CODE_ADD => q{The new Freiker ID was added.},
	    CLUB_PRIZE => 'The required rides for the prize were updated.',
	    CLUB_FREIKER_CODE_IMPORT => 'New codes imported successfully.',
	    MERCHANT_PRIZE => 'Thank you for your donation or update.  Please contact vs_gears_email(); to discuss prize delivery and inventory management.',
	    GENERAL_USER_PASSWORD_QUERY => <<'EOF',
An email has been sent to
String([qw(Model.UserPasswordQueryForm Email.email)]);.
The email contains a link back to this site so
you can reset your password.
EOF
	    paypal_ok => <<'EOF',
SPAN_money('Thank you very much for your donation!');
Your transaction has been completed, and a receipt for your
purchase has been emailed to you. You may log into your account
at XLink('paypal'); to view details of this transaction.
EOF
	    paypal_cancel => q{Your donation has been cancelled.  Please consider donating in the future.},
	    CLUB_FREIKER_PRIZE_CONFIRM => q{Please give the child the selected prizes.},
	]],
	[xlink => [
	    paypal => 'PayPal',
	    login_no_context => 'Login',
	    user_create_no_context => 'Register',
	]],
	[FAMILY_PRIZE_COUPON_LIST => 'Prizes'],
	[FAMILY_FREIKER_RIDE_LIST => 'Rides'],
	[FAMILY_MANUAL_RIDE_FORM => 'Add missing ride'],
	[FAMILY_FREIKER_CODE_ADD => 'New tag'],
	[FAMILY_PRIZE_SELECT => 'Select prize'],
	[PAYPAL_FORM => ''],
	[title => [
	    CLUB_FREIKER_LIST => 'Freikers',
	    CLUB_RIDE_DATE_LIST => 'Rides by Date',
	    CLUB_REGISTER => 'Register Your School',
	    CLUB_PRIZE => q{Update Prize String(['Model.ClubPrizeList', 'Prize.name']);},
	    CLUB_PRIZE_LIST => 'School Prizes',
	    CLUB_FREIKER_CODE_IMPORT => 'Import Codes',
	    MERCHANT_PRIZE => q{If(['Type.FormMode', '->eq_edit'], 'Update Prize Information', 'Donate a Prize');},
	    MERCHANT_PRIZE_LIST => 'Donated Prizes',
	    MERCHANT_REGISTER => 'Register Your Business',
	    MERCHANT_PRIZE_REDEEM => 'Enter a Prize Coupon',
	    MERCHANT_PRIZE_RECEIPT => 'Prize Authorization',
	    FAMILY_PRIZE_CONFIRM => 'Confirm Your Prize Selection',
	    FAMILY_PRIZE_COUPON => 'Prize Coupon',
	    FAMILY_PRIZE_COUPON_LIST => q{Past Prizes},
	    FAMILY_PRIZE_SELECT => q{Congratulations! Choose a Prize! You have String([qw(Model.PrizeSelectList ->get_prize_credit)]); credits.},
	    FAMILY_FREIKER_ADD => 'Register Your Child',
	    FAMILY_FREIKER_LIST => "Your Freikers",
	    USER_CREATE => 'Please Register',
	    LOGIN => 'Please Login',
	    ADM_SUBSTITUTE_USER => 'Act as User',
	    ADM_FREIKOMETER_LIST => 'Freikometers',
	    ADM_PRIZE_LIST => 'All Prizes',
	    ADM_PRIZE_COUPON_LIST => 'All Delivered Prizes',
	    CLUB_PRIZE_COUPON_LIST => 'Delivered Prizes',
	    ADM_PRIZE => 'Update prize',
	    USER_PASSWORD => 'Change Your Password',
	    [qw(USER_CREATE_DONE GENERAL_USER_PASSWORD_QUERY)] => 'Check Your Mail',
	    ALL_CLUB_SUMMARY_LIST => 'Real-time Ridership',
	    MERCHANT_FILE => 'Files',
	    CLUB_FREIKER_SELECT => 'Deliver Prize',
	    CLUB_FREIKER_PRIZE_CONFIRM => 'Confirm Prize Selection',
	    CLUB_FREIKER_PRIZE_SELECT => 'Select Prize',
	    CLUB_FREIKER_MANUAL_RIDE_FORM => 'Give Rides',
	    GENERAL_PRIZE_LIST => 'Possible Prizes',
	]],
	['xhtml.title' => [
	    FAMILY_FREIKER_RIDE_LIST =>
		'String([qw(Model.FreikerRideList ->get_display_name)]); Rides',
	    FAMILY_MANUAL_RIDE_FORM =>
		'Add Missing Ride for String([qw(Model.FreikerRideList ->get_display_name)]);',
	    FAMILY_FREIKER_CODE_ADD =>
		'Enter New Freiker ID for String([qw(Model.FreikerRideList ->get_display_name)]);',
	    CLUB_FREIKER_MANUAL_RIDE_FORM =>
		'Give rides to String([qw(Model.FreikerRideList ->get_display_name)]);',
	    CLUB_FREIKER_PRIZE_SELECT => q{Select Prize for String([qw(Model.ClubFreikerList RealmOwner.display_name)]); with String([qw(Model.ClubPrizeSelectList ->get_prize_credit)]); credits},
	    FAMILY_PRIZE_PICKUP => 'Where to pickup your prize!',
	]],
	['task_menu.title' => [
#TODO: Remove 1/15/08
	    GENERAL_CONTACT => 'Contact',
	    CLUB_FREIKER_LIST => 'Freikers',
	    CLUB_RIDE_DATE_LIST => 'Rides',
	    CLUB_PRIZE => 'Update prize',
	    CLUB_PRIZE_LIST => 'Available prizes',
	    CLUB_REGISTER => 'Register new school',
	    FAMILY_FREIKER_ADD => 'Register child',
	    FAMILY_FREIKER_LIST => 'Your family',
	    FAMILY_PRIZE_COUPON_LIST => 'Past prizes',
	    FAMILY_PRIZE_SELECT => 'Choose prize',
	    LOGIN => 'Login',
	    MERCHANT_PRIZE => 'Add prize',
	    MERCHANT_PRIZE_REDEEM => 'Redeem coupon',
	    MERCHANT_PRIZE_LIST => 'Donated prizes',
	    MERCHANT_REGISTER => 'Register new merchant',
	    PAYPAL_FORM => 'Donate',
	    SITE_ROOT => 'Home',
	    USER_CREATE => 'Register',
	    USER_PASSWORD => 'Account',
	    back_to_family => 'Your family',
	    back_to_school => 'School',
	]],
    ],
});

1;
