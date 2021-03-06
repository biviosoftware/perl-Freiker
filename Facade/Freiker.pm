# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Facade::Freiker;
use strict;
use Bivio::Base 'Bivio::UI::FacadeBase';


my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    uri => 'boltage',
    http_host => 'my.boltage.org',
    mail_host => 'my.boltage.org',
    Color => [
	[fr_footer => 0x0],
	[[qw(
	    a_link
	    acknowledgement_border
	    title
	    fr_body
	)] => 0x444444],
	[a_hover => 0x888888],
	[[qw(err warn empty_list_border)] => 0xcc0000],
	# green
	[[qw(fr_header_background fr_footer_background)] => 0xccdd22],
	[fr_main_center_border => 0x33ccff],
	[select_prize => 0xffcf06],
	[table_separator => 0x000000],
    ],
    Font => [
	[a_link => 'normal'],
	[a_hover => 'underline'],
	[fr_body => 'family=Arial, Helvetica, sans-serif'],
	[highlight => 'bold'],
	[select_prize => [qw(bold underline)]],
	[fr_footer => [qw(size=9pt bold italic uppercase nowrap)]],
    ],
    FormError => [
	[NUMBER => 'Please enter a number'],
	['PrizeCoupon.coupon_code.NOT_FOUND' => q{The vs_fe(q{label}); is not valid.  Please verify the number carefully.  If you already did this, please have the parent contact us at vs_gears_email();.}],
	['PayPalForm.amount.NULL' => 'Any amount will do!'],
	['FreikerCode.freiker_code' => [
	    NOT_FOUND => q{This is not a valid vs_fe('label'); for your school.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.},
	    EXISTS => q{The vs_fe('label'); is already assigned to a kid.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.If(['->is_substitute_user'], SPAN_sui(' To force the assignment, resubmit the form.'));},
	    MUTUALLY_EXCLUSIVE => q{The vs_fe(q{label}); was scanned on vs_fe(q{detail}); when your kid also rode with his old vs_fe(q{label});.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.If(['->is_substitute_user'], SPAN_sui(' To force the assignment, resubmit the form.'));},
	    SYNTAX_ERROR => q{Field must be blank if registering without ZapTag.},
	]],
	['SchoolClassListForm.RealmOwner.display_name.EXISTS' => q{A teacher with name appears above.  Teachers' names must be unique.}],
	['ClubRegisterForm.Website.url.EXISTS' => q{This school's website is already registered.  Please try to find the volunteer at your school.}],
	['ClubRegisterForm.club_name.EXISTS' => q{Your school is already registered.  Please try to find the volunteer at your school.}],
	['email.EXISTS' => q{This email is already registered with vs_site_name();.  Link('Click here to login.', 'LOGIN', {no_context => 1});}],
	['Ride.ride_date.NOT_FOUND' => q{This date was not a school day. Or, the ZAP did not send the trips to boltage.org (yet).  The ZAP stores the trips until it can get a network connection.  Sometimes the network is down for days.}],
	['Ride.ride_date' => [
	    DATE_RANGE => q{Date cannot be in the future},
	    SYNTAX_ERROR => q{Date cannot be on a weekend},
	    EXISTS => q{The kid was already credited for this date.  Please enter a different date.},
	]],
	['PrizeConformForm.Prize.name.TOO_FEW' => q{You do not have enough available trips to chose this prize}],
	['UserLoginForm.login.OFFLINE_USER' => q{Not a registered Boltage Code.  Link('Please click on this link to register.', 'USER_CREATE');}],
	[[qw(AdmSubstituteUserForm SiteAdminSubstituteUserForm)] => [
	    'login.OFFLINE_USER' => q{Boltage Code not registered.  User must register before you can act as user.},
	]],
	['FreikerSelectForm.FreikerCode.freiker_code.NOT_FOUND' => q{Boltage Code is not in our database.}],
	['FreikerSelectForm.FreikerCode.freiker_code.PERMISSION_DENIED' => q{Kid is not at this school.}],
	['GreenGearForm.GreenGear.begin_date.GREATER_THAN_ZERO' => q{Weekly Winner must be after most recent Weekly Winner (DateTime(['Model.GreenGearList', 'GreenGear.end_date']);)}],
	[[qw(GreenGearForm.GreenGear.end_date.TOO_MANY GreenGearForm.GreenGear.begin_date.TOO_MANY)],
	 => q{vs_fe('label'); may not be in the future.}],
	['GreenGearForm.GreenGear.end_date.MUTUALLY_EXCLUSIVE' => q{Last Day must not be before First}],
	['GreenGearForm.GreenGear.begin_date.EMPTY' => q{No trips found between First and Last Days}],
	['GreenGearForm.GreenGear.begin_date.EXISTS' => q{All eligible kids have already won at least once.  Uncheck the "prior winners" box to select one of these kids, or change the date range.}],
	['GreenGearForm.GreenGear.begin_date.UNSUPPORTED_TYPE' => q{None of the eligible kids is registered.  Uncheck the "must be registered" box to select one of these kids, or change the date range.}],
	['ClubRideFillForm.Ride.ride_date.NOT_NEGATIVE' => q{You are a new school. Please be patient.  You may not fill in trips before the ZAP has been working.}],
	['ClubRideFillForm.Ride.ride_date.EXISTS' => q{ZAP was working this day.}],
	['AdmFreikerCodeReallocateForm.FreikerCode.freiker_code.NOT_FOUND' =>
	     q{ZapTag not found in this school.}],
	['AdmFreikerCodeReallocateForm.FreikerCode.freiker_code.EXISTS' =>
	     q{Block contains assigned ZapTags.}],
	['AdmFreikerCodeReallocateForm.dest.Club.club_id.SYNTAX_ERROR' =>
	     q{Schools cannot be the same.}],
    ],
    Constant => [
	[xlink_paypal => {
	    uri => 'http://www.paypal.com/us',
	}],
	[xlink_all_users => {
	    task_id => 'SITE_ADMIN_USER_LIST',
	    realm => 'site-admin',
	}],
	[site_zap_realm => 'site-zap'],
	[my_site_redirect_map => sub {[
	    [qw(GENERAL ADMINISTRATOR ADM_FREIKOMETER_LIST)],
	    [qw(MERCHANT ADMINISTRATOR MERCHANT_PRIZE_REDEEM)],
	    [qw(CLUB ADMINISTRATOR CLUB_FREIKER_LIST)],
	    [qw(USER ADMINISTRATOR FAMILY_FREIKER_LIST)],
	]}],
	[ThreePartPage_want_SearchForm => 0],
	[ThreePartPage_want_ForumDropDown => 1],
	[ThreePartPage_want_dock_left_standard => 1],
    ],
    Task => [
	[MERCHANT_HOME => '?'],
	[SCHOOL_CLASS_HOME => '?'],
	[ADM_FREIKOMETER_LIST => ['adm/zaps', 'adm/freikometers']],
	[ALL_CLUB_SUMMARY_LIST => ['pub/trip-summary', 'pub/ride-summary']],
	[BOT_FREIKOMETER_DOWNLOAD => '?/fm-down/*'],
	[BOT_FREIKOMETER_UPLOAD => '/fm/*'],
	[CLUB_FREIKER_LIST => ['?/kids', '?/freikers']],
	[CLUB_FREIKER_CLASS_LIST_FORM => ['?/kids-classes', '?/freikers-classes']],
	[CLUB_FREIKER_LIST_CSV => ['?/kids.csv', '?/freikers.csv']],
	[CLUB_FREIKER_CLASS_LIST => ['?/class-kids', '?/class-freikers']],
	[CLUB_FREIKER_MANUAL_RIDE_FORM => ['?/give-trips', '?/give-rides']],
	[CLUB_PRIZE => '?/prize'],
	[CLUB_PRIZE_LIST => '?/prizes'],
	[CLUB_PRIZE_COUPON_LIST => '?/prize-coupons'],
	[BOT_ZAP_UPLOAD => '/dz'],
	[BOT_HUB_UPLOAD => '/sh/*'],
	[ADM_PRIZE_LIST => 'adm/prizes'],
	[ADM_PRIZE_COUPON_LIST => 'adm/prize-coupons'],
	[ADM_PRIZE => 'adm/prize'],
	[CLUB_REGISTER => '/pub/register-school'],
	[CLUB_RIDE_DATE_LIST => ['?/trip-dates', '?/ride-dates']],
	[CLUB_FREIKER_CODE_IMPORT => '?/import-codes'],
	[CLUB_FREIKER_SELECT => '?/select-kid'],
	[CLUB_FREIKER_PRIZE_SELECT => '?/select-prize'],
	[CLUB_FREIKER_PRIZE_CONFIRM => '?/confirm-prize'],
	[CLUB_FREIKER_ADD => '?/register-kid'],
	[CLUB_FREIKER_CODE_ADD => '?/add-tag'],
	[CLUB_FREIKER_EDIT => '?/edit-kid'],
	[CLUB_FREIKER_RIDE_LIST => ['?/trips', '?/rides']],
	[CLUB_MANUAL_RIDE_FORM => ['?/add-trip', '?/add-ride']],
	[CLUB_MANUAL_RIDE_LIST_FORM => ['?/add-trips', '?/add-rides']],
	[FAMILY_FREIKER_ADD => '?/register-kid'],
	[FAMILY_FREIKER_CODE_ADD => '?/add-tag'],
	[FAMILY_FREIKER_EDIT => '?/edit-kid'],
	[FAMILY_FREIKER_LIST => '?/kids'],
	[FAMILY_FREIKER_RIDE_LIST => ['?/trips', '?/rides']],
	[FAMILY_MANUAL_RIDE_FORM => ['?/add-trip', '?/add-ride']],
	[FAMILY_PRIZE_CONFIRM => '?/confirm-prize'],
	[FAMILY_PRIZE_COUPON => '?/prize-coupon'],
	[FAMILY_PRIZE_COUPON_LIST => '?/prize-coupons'],
	[FAMILY_PRIZE_SELECT => '?/select-prize'],
	[FAMILY_PRIZE_PICKUP => '?/pickup-prize'],
	[FAMILY_MANUAL_RIDE_LIST_FORM => ['?/add-trips', '?/add-rides']],
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
	[GREEN_GEAR_FORM => '?/select-green-gear'],
	[GREEN_GEAR_LIST => '?/green-gears'],
	[CLUB_RIDE_FILL_FORM => ['?/fill-trips', '?/fill-rides']],
	[CLUB_FREIKER_PRIZE_DELETE => '?/return-prize'],
	[CLUB_SCHOOL_CLASS_LIST_FORM => '?/classes'],
	[USER_ACCEPT_TERMS_FORM => 'bp/Accept_Terms'],
	[CLUB_FREIKER_IMPORT_EMPTY_CSV => '?/import-kids.csv'],
	[CLUB_FREIKER_IMPORT_FORM => '?/import-kids'],
	[ADM_SUMMARY_BY_SCHOOL_LIST => 'adm/summary-by-school'],
	[CLUB_SUMMARY_BY_CLASS_LIST => '?/summary-by-class'],
	[GROUP_USER_BULLETIN_LIST_CSV => '?/subscribers.csv'],
	[ADM_FREIKER_CODE_REALLOCATE_FORM => 'adm/reallocate-tags'],
	[ADM_FREIKER_CODE_REALLOCATE_CONFIRM => 'adm/reallocate-tags-confirm'],
	[CLUB_PROFILE_FORM => '?/school-profile'],
    ],
    Text => [
	[support_email => 'info@boltage.org'],
	[contact_email => 'info@boltage.org'],
#TODO:	    [support_phone => '(800) 555-1212'],
	[site_name => q{Boltage}],
	[site_copyright => q{KidCommute, Inc.}],
	[privacy_policy => 'Privacy Policy'],
	[terms_of_service => 'Terms of Service'],
	[find_us_on_facebook => 'Find us on FaceBook'],
	[home_page_uri => '/my-site'],
	[Image_alt => [
	    at => 'at sign image to help avoid spam',
	    bivio_power => 'Operated by bivio Software, Inc.',
	]],
	[['email', 'login'] => 'Your Email'],
	[club_name => 'Official Name'],
	[freiker_code => q{ZapTag}],
	[club_id => q{School}],
	[school_class_id => 'Class'],
	[ride_count => 'Trips'],
	[prize_debit => 'Spent'],
	[prize_credit => 'Credits'],
	[freiker_codes => 'ZapTag'],
	[parent_display_name => 'Parent'],
	[parent_display_name_sort => 'Parent'],
	[parent_last_name => 'Parent Last Name'],
	[parent_middle_name => 'Parent Middle Name'],
	[parent_first_name => 'Parent First Name'],
	[parent_zip => 'Parent Zip'],
	[parent_email => 'Email'],
	[[qw(kilometers distance_kilometers)] => 'Kilometers'],
	[miles => 'Miles'],
	['User.gender' => 'Gender'],
	[birth_year => q{Year of Birth}],
	['User.birth_date' => 'Birthday'],
	[list_actions => 'Actions'],
	[school_grade => 'Grade'],
	[[qw(GroupUserList.privileges_name RoleSelectList.display_name)] => [
	    FREIKOMETER => 'ZAP',
	]],
	[Ride => [
	    ride_date => 'Date',
	    ride_type => 'Mode',
	]],
	['WikiView.start_page' => 'Home'],
	[Address => [
	     country => 'Country Code',
	     'country.desc' => 'Official two-letter country code (US, CA, MX, etc.)',
	     zip => 'Postal Code',
	]],
	[ClubRegisterForm => [
	    'club_size' => 'Number of Students',
	    'club_size.desc' => 'Total number of students including kids and non-kids.',
	    'Website.url' => 'School Website',
	    'Website.url.desc' => 'Example: http://schools.bvsd.org/crestview/index.html',
	    allow_tagless => 'Allow Kids to Register Without ZapTags',
	    SchoolContact => [
		display_name => 'Support Contact Name',
		email => 'Support Contact Email',
	    ],
	    ok_button => q{If([[qw(->req Type.FormMode)], 'eq_create'], 'Register school', 'Update profile');},
	]],
	[MerchantInfoForm => [
	    prose => [
		prologue => q{vs_site_name(); uses local merchants as distribution points for prizes.  You may also donate prizes and manage the prize descriptions through this website.  Once you are registered, we'll contact you about prize logistics and fees.},
            ],
	    'RealmOwner.display_name' => 'Business Name',
	    'Website.url' => 'Business Website',
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
	    ride_count => 'Required Trips',
	]],
	[[qw(AdmPrizeCouponList ClubPrizeCouponList)] => [
	    'PrizeCoupon.creation_date_time' => 'Delivered',
	    'Prize.name' => 'Prize',
	    'RealmOwner.display_name' => 'Kid',
	    family_display_name => 'Parent',
	    'list_action.CLUB_FREIKER_PRIZE_DELETE' => 'Return',
	]],
	[ClubPrizeDeleteForm => [
	    'prose.prologue' => q{Return the String([qw(Model.ClubPrizeCouponList Prize.name)]); and credit String([qw(Model.ClubPrizeCouponList ->get_display_name)]); with String([qw(Model.PrizeCoupon ride_count)]); trips?},
	    ok_button => 'Return Prize',
	]],
	[[qw(MerchantPrizeForm AdmPrizeForm)] => [
	    image_file => 'Image',
	    ok_button => 'OK',
	]],
	[GreenGear => [
	    begin_date => 'First Day',
	    end_date => 'Last Day',
	    must_be_unique => 'If possible, prior winners are not eligible.',
	    must_be_registered => 'Kid must be registered in order to win.',
	]],
	[GreenGearList => [
	    'RealmOwner.display_name' => 'Kid',
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
		prologue => q{Please enter the Kid's vs_text_as_prose('PrizeReceipt.coupon_code');.},
	    ],
	    ok_button => 'Redeem',
	]],
	[PrizeRideCount => [
	    ride_count => 'Trip Count',
	]],
	[SchoolClassList => [
	    display_name => __PACKAGE__->init_from_prior_group('school_class_id'),
	    unknown_label => 'Select Class',
	]],
	[UserRegisterForm => [
	    prose => [
		prologue => q{P('In order to better serve you, we validate all email addresses.  When you click Register, we will email you a link which will ask you to set your password.');},
		epilogue => <<'EOF',
P(vs_text_as_prose('LOGIN'));
P(Join([
    q{By clicking on 'I accept' below you are agreeing to the },
    Link('Terms of Service', '/bp/Terms_of_Service'),
    ' and the ',
    Link('Privacy Policy', '/bp/Privacy_Policy'),
    '.',
]));
</p>
EOF
	    ],
	    'Email.email.desc' =>
		q{We only send emails related to vs_site_name();.},
	    'RealmOwner.display_name' => 'Your Name',
	    'RealmOwner.display_name.desc' => q{Your first and last name, not your business or school's name.},
	    ok_button => 'I accept. Create my account.',
	]],
	['FreikerCodeForm.prose.prologue' => q{If(['Model.FreikerCodeForm', 'in_parent_realm'], Prose(q{Enter the new Boltage Code from the ZapTag on your kid's backpack.  If the ZapTag is missing from your kid's backpack, or you need another ZapTag for a new backpack, vs_wheel_contact<(>)<;>.}), vs_text_as_prose('FreikerForm.prose.prologue'));}],
	['FreikerForm.prose.prologue' => q{If(['!', 'form_model', 'in_parent_realm'], Link("Click here to edit your school's class list.", 'CLUB_SCHOOL_CLASS_LIST_FORM'));}],
	[[qw(FreikerForm FreikerCodeForm)] => [
	    'User.first_name' => q{First},
	    'User.middle_name' => q{Middle},
	    'User.last_name' => q{Last},
	    'birth_year' => q{Year of Birth},
	    'User.gender' => q{Gender},
	    has_graduated => 'Has Graduated',
	    kilometers => 'Kilometers to School',
	    miles => 'Miles to School',
	    no_freiker_code => 'Register without ZapTag',
	    [qw(miles kilometers)] => [
		desc => q{One-way distance from your home to this kid's school.  Kids with multiple homes, calculate the distance from the home associated with the postal code above.},
	    ],
	    default_ride_type => 'Default Trip Mode',
	    ok_button => q{If([qw(->ureq Model.FreikerRideList)], 'Add ZapTag', 'Register kid');},
	]],
	[FreikerForm => [
	    ok_button => 'Update Info',
	]],
	[FreikerImportForm => [
	    'prose.prologue' => q{Use this form to register a group of kids in one go.  Link('Click here for the sample spreadsheet', 'CLUB_FREIKER_IMPORT_EMPTY_CSV');.  You may want Link("to edit your school's class list before uploading", 'CLUB_SCHOOL_CLASS_LIST_FORM');.},
	    source => 'CSV File',
	    ok_button => 'Import Kids',
	    error => [
		both_kilometers_miles => 'only one of Kilometers or Miles may be specified',
		none_kilometers_miles => 'one of Kilometers or Miles must be specified',
		teacher_not_found =>  'Teacher not found in list of classes',
		freiker_code_not_found => 'ZapTag not found in the database',
		freiker_code_already_registered => 'ZapTag is already assigned to a kid',
		country_null => 'Country must be specified for first kid',
		zip_invalid => 'US Zip codes must be 5 or 9 digits',
	    ],
	]],
	[ClubManualRideForm => [
	    add_days => 'Number of Days',
	    ok_button => 'Give trips',
	]],
	[ManualRideForm => [
	    'Ride.ride_date' => q{Date Missing},
	    ok_button => 'Add trip',
	    prose => [
		prologue => <<'EOF',
We allow a certain number of missed trips as a courtesy to parents.
When there are too many missed trips, this list will no longer show.
Please enter the date of the missing trip for
String([qw(Model.FreikerRideList ->get_display_name)]);.
EOF
	    ],
	]],
	[ManualRideListForm => [
	    use_type_for_all => 'Same Mode for All',
	    map((
		"sibling$_" => qq{String([qw(->req Model.ManualRideListForm sibling_name$_)]);},
	    ), (0 .. 9)),
	    ok_button => 'Add trips',
	    prose => [
		prologue => <<'EOF',
Last Trip: If([qw(Model.ManualRideListForm last_ride)], Join([DateTime([qw(Model.ManualRideListForm last_ride ride_date)], 'DATE'), ' (', String([qw(Model.ManualRideListForm last_ride ride_type ->get_short_desc)]), ')']), 'None');
EOF
		also_siblings => 'Also add these trips for:',
	    ],
	]],
	[AdmFreikometerList => [
	    'RealmOwner.name' => 'ZAP',
	    'RealmOwner.display_name' => 'MAC',
	    modified_date_time => 'Last Upload',
	    'list_action.FORUM_FILE_TREE_LIST' => 'Files',
	]],
	[separator => [
	    optional_address => 'Optional information to help us contact you',
	    optional_statistics => 'Optional information used for statistical purposes',
	]],
	[[qw(FreikerList ClubFreikerList ClubFreikerClassList)] => [
	    [qw(User.first_name display_name)] => 'Kid',
	    school_class_display_name => 'Teacher',
	    empty_list_prose => 'No Kids as yet.',
	    miles => 'One Way Miles',
	    current_miles => 'Total Miles',
	    'FreikerInfo.distance_kilometers' => 'One Way Kilometers',
	    current_kilometers => 'Total Kilometers',
	    class_display_name => 'Class',
	    school_class_id => 'Class ID',
	    new_school_class_id => 'Updated Class',
	    has_graduated => 'Graduated',
	    new_has_graduated => 'Updated Graduated',
	    has_graduated_false => '',
	    has_graduated_true => 'x',
	    calories => 'Calories Burned',
	    co2_saved => 'Pounds of CO2 Saved',
	]],
	[ClubRideList => [
	    'unassigned_class' => 'Unassigned',
	]],
	[[qw(AdmSummaryBySchoolList ClubSummaryByClassList)] => [
	    class_display_name => 'Class',
	    display_name_summary_value => 'Totals',
	    current_miles => 'Total Miles',
	    current_kilometers => 'Total Kilometers',
	    calories => 'Calories Burned',
	    co2_saved => 'Pounds of CO2 Saved',
	]],
	[AdmSummaryBySchoolList => [
	    'realm_display_name' => 'School',
	]],
	[ClubSummaryByClassList => [
	    'realm_display_name' => 'Class',
	]],
	[ClubFreikerClassListForm => [
	    'prose.prologue' => q{If(['!', 'auth_realm', 'type', '->eq_user'], Link("Click here to edit your school's class list.", 'CLUB_SCHOOL_CLASS_LIST_FORM'));},
	    has_graduated => '',
	    new_has_graduated => '',
	    ok_button => 'Update',
	]],
	[summary_headings => [
	    ride_count => 'Total Trips',
	    current_miles => 'Total Miles',
	    calories => 'Total Calories Burned',
	    trips => 'Total Trips',
	    trip_miles => 'Total Miles',
	    co2_saved => 'Pounds of CO2 Saved',
	]],
	[FreikerListQueryForm => [
	    fr_year => 'All Years',
	    fr_trips => 'Has Trips',
	    fr_all => 'All Schools',
	    fr_registered => 'Registered',
	    fr_current => 'Current Students Only',
	    ok_button => 'Refresh',
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
	[ClubRideFillForm => [
	    'prose.prologue' => 'This form is used to fill in trips for days when the ZAP did not operate.  Trips will be added for all Kids who rode on two days before and after the date you specified.',
	    'Ride.ride_date' => 'Date Without Trips',
	]],
	[AllClubSummaryList => [
	    'RealmOwner.display_name' => 'School',
	    days_1 => 'Day',
	    days_5 => 'Week',
	    days_20 => 'Month',
	    days_10000 => 'All',
	]],
	[UserPasswordQueryForm => [
	    'prose.prologue' => q{P_prose('Please enter the email address you used to register and click Send.  You will receive an email with a link to reset your password.');},
	    ok_button => 'Send',
	]],
	[[qw(SchoolClassListForm SchoolClassList)] => [
	    'prose.prologue' => q{To add a class, enter the information in a blank row.  To delete a class, clear the values in the row.},
	    'RealmOwner.display_name' => 'Teacher',
	]],
	[prose => [
	    wiki_by_line => '',
	    LOGIN => q{Already registered?  Link('Click here to login.', {task_id => 'LOGIN', no_context => 1});},
	    USER_CREATE => q{Kid not registered?  vs_link('Click here to register.', 'USER_CREATE');},
	    CLUB_REGISTER => q{Would you like to become a volunteer? vs_link('Click here to register your school.', 'CLUB_REGISTER');},
	    MERCHANT_REGISTER => q{Are you a merchant? vs_link('Click here to register your business.', 'MERCHANT_REGISTER');},
	    GENERAL_USER_PASSWORD_QUERY => q{Forgot your password? Link('Click here to get a new one.', 'GENERAL_USER_PASSWORD_QUERY');},
	    UserAuth => [
		create_mail => [
		    to => q{Mailbox([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']);},
		    subject => q{Join([vs_site_name(), ' Registration Verification']);},
		    body => <<'EOF'
Thank you for registering with vs_site_name();.  In order to
complete your registration, please click on the following link:

String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'uri']);

String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']); is the email address we have for you in our database.
You will use this address to login along with the password you
will set when you click on the above link.

Thanks for registering.  Every Trip Counts!TM

KidCommute, Inc.
Link('SITE_ROOT');

KidCommute, Inc. (EIN 56-2539016) is a tax-exempt organization under Section
501(c)3 of the Internal Revenue Code. Your donation is tax deductible to the
full extent of the law.  Just $10 will help:
KidCommute, Inc. (EIN 56-2539016) is a tax-exempt organization under
Section 501(c)(3) of the Internal Revenue Code. Your donation is tax
deductible to the full extent of the law - Link('/site/donate');

EOF
		],
	    ],
	]],
	[ContactForm => [
	    to => 'To',
	]],
	[AdmFreikerCodeReallocateForm => [
	    'prose.prologue' => 'Only entire blocks of ZapTags that have not been assigned can be reallocated.',
	    'source.Club.club_id' => 'From',
	    'dest.Club.club_id' => 'To',
	    'FreikerCode.freiker_code' => 'Sample ZapTag',
	    'FreikerCode.freiker_code.desc' => 'The block that this ZapTag belongs to will be reallocated.',
	    'ok_button' => 'Reallocate',
	]],
	[AdmFreikerCodeReallocateConfirmationForm => [
	    'prose.prologue' => q{Are you sure you want to reallocate all STRONG(String([qw(Model.AdmFreikerCodeReallocateForm num_tags)])); ZapTags starting with STRONG(String([qw(Model.AdmFreikerCodeReallocateForm tag_block)])); from STRONG(String([qw(Model.AdmFreikerCodeReallocateForm source.RealmOwner.display_name)])); to STRONG(String([qw(Model.AdmFreikerCodeReallocateForm dest.RealmOwner.display_name)]));?},
	    'ok_button' => 'Reallocate',
	]],
	[SchoolContactList => [
	    unknown_label => 'Select School Contact',
	]],
	[ClubList => [
	    unknown_label => 'Select School',
	]],
	[acknowledgement => [
	    update_address => q{Please update the information below.  We need to make sure your information is current.},
	    GREEN_GEAR_FORM => q{The new Weekly Winner appears below.  Please notify the kid that he or she has won.},
	    CLUB_REGISTER => q{Your school has been registered.},
	    CLUB_RIDE_FILL_FORM => q{Filled in missing trips for when ZAP was not working.},
	    MERCHANT_REGISTER => q{Your business has been registered.},
	    [qw(FAMILY_FREIKER_ADD CLUB_FREIKER_ADD)]
		=> q{The kid has been added.},
	    [qw(FAMILY_MANUAL_RIDE_FORM CLUB_MANUAL_RIDE_FORM)]
		=> q{The missing date has been added.},
	    [qw(FAMILY_FREIKER_CODE_ADD CLUB_FREIKER_CODE_ADD)]
		=> q{The new Boltage Code was added.},
	    [qw(FAMILY_FREIKER_EDIT CLUB_FREIKER_EDIT)]
		=> q{The kid's info was updated.},

	    CLUB_PRIZE => 'The required trips for the prize were updated.',
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
	    CLUB_FREIKER_PRIZE_CONFIRM => q{Please give the kid the selected prizes.},
	    CLUB_FREIKER_CLASS_LIST_FORM => q{Classes Updated},
	    ADM_FREIKER_CODE_REALLOCATE_CONFIRM => q{ZapTags reallocated.},
	]],
	[xlink => [
	    paypal => 'PayPal',
	    login_no_context => 'Login',
	    user_create_no_context => 'Register',
	]],
	[FAMILY_PRIZE_COUPON_LIST => 'Prizes'],
	[[qw(FAMILY_FREIKER_RIDE_LIST CLUB_FREIKER_RIDE_LIST)] => 'Trips'],
	[[qw(FAMILY_MANUAL_RIDE_FORM CLUB_MANUAL_RIDE_FORM)] => 'Add missing trip'],
	[[qw(FAMILY_MANUAL_RIDE_LIST_FORM
	     CLUB_MANUAL_RIDE_LIST_FORM)] => 'Add missing trips'],
	[[qw(FAMILY_FREIKER_CODE_ADD CLUB_FREIKER_CODE_ADD)] => 'New ZapTag'],
	[[qw(FAMILY_FREIKER_EDIT CLUB_FREIKER_EDIT)] => 'Edit info'],
	[FAMILY_PRIZE_SELECT => 'Select prize'],
	[PAYPAL_FORM => ''],
	[title => [
	    USER_ACCEPT_TERMS_FORM => 'Accept Terms of Service and Privace Policy',
	    CLUB_FREIKER_LIST => 'Kids',
	    CLUB_FREIKER_CLASS_LIST => q{Kids in String([qw(Model.ClubFreikerClassList ->get_class_display_name)]);},
	    CLUB_FREIKER_CLASS_LIST_FORM => 'Update Kids Classes',
	    CLUB_RIDE_DATE_LIST => 'Trips by Date',
	    CLUB_REGISTER => 'Register Your School',
	    CLUB_PRIZE => q{Update Prize String(['Model.ClubPrizeList', 'Prize.name']);},
	    CLUB_PRIZE_LIST => 'School Prizes',
	    CLUB_FREIKER_CODE_IMPORT => 'Import Codes',
	    CLUB_RIDE_FILL_FORM => 'Fill Trips',
	    MERCHANT_PRIZE => q{If(['Type.FormMode', '->eq_edit'], 'Update Prize Information', 'Donate a Prize');},
	    MERCHANT_PRIZE_LIST => 'Donated Prizes',
	    MERCHANT_REGISTER => 'Register Your Business',
	    MERCHANT_PRIZE_REDEEM => 'Enter a Prize Coupon',
	    MERCHANT_PRIZE_RECEIPT => 'Prize Authorization',
	    FAMILY_PRIZE_CONFIRM => 'Confirm Your Prize Selection',
	    FAMILY_PRIZE_COUPON => 'Prize Coupon',
	    FAMILY_PRIZE_COUPON_LIST => q{Past Prizes},
	    FAMILY_PRIZE_SELECT => q{Congratulations! Choose a Prize! You have String([qw(Model.PrizeSelectList ->get_prize_credit)]); credits.},
	    FAMILY_FREIKER_ADD => 'Register Your Kid',
	    CLUB_FREIKER_ADD => 'Register a Kid',
	    FAMILY_FREIKER_LIST => 'Your Kids',
	    USER_CREATE => 'Please Register',
	    LOGIN => 'Please Login',
	    ADM_SUBSTITUTE_USER => 'Act as User',
	    ADM_FREIKOMETER_LIST => 'ZAPs',
	    ADM_PRIZE_LIST => 'All Prizes',
	    ADM_PRIZE_COUPON_LIST => 'All Delivered Prizes',
	    CLUB_PRIZE_COUPON_LIST => 'Delivered Prizes',
	    ADM_PRIZE => 'Update prize',
	    USER_PASSWORD => 'Change Your Password',
	    [qw(USER_CREATE_DONE GENERAL_USER_PASSWORD_QUERY)] => 'Check Your Mail',
	    ALL_CLUB_SUMMARY_LIST => 'Real-time Trips',
	    MERCHANT_FILE => 'Files',
	    CLUB_FREIKER_SELECT => 'Deliver Prize',
	    CLUB_FREIKER_PRIZE_CONFIRM => 'Confirm Prize Selection',
	    CLUB_SCHOOL_CLASS_LIST_FORM => 'Classes',
	    CLUB_FREIKER_PRIZE_SELECT => 'Select Prize',
	    CLUB_FREIKER_MANUAL_RIDE_FORM => 'Give Trips',
	    GENERAL_PRIZE_LIST => 'Possible Prizes',
	    GREEN_GEAR_LIST => 'Weekly Winners',
	    GREEN_GEAR_FORM => 'Choose Weekly Winner',
	    CLUB_FREIKER_PRIZE_DELETE => q{Return Prize for String([qw(Model.ClubPrizeCouponList ->get_display_name)]);},
	    CLUB_FREIKER_IMPORT_FORM => 'Import Kids',
	    ADM_SUMMARY_BY_SCHOOL_LIST => 'Trip Summary by School',
	    CLUB_SUMMARY_BY_CLASS_LIST => 'Trip Summary by Class',
	    GROUP_USER_BULLETIN_LIST_CSV => 'Subscribers (CSV)',
	    CLUB_MANUAL_RIDE_LIST_FORM => q{Add Missing Trips for String([qw(Model.ManualRideListForm RealmOwner.display_name)]);},
	    FAMILY_MANUAL_RIDE_LIST_FORM => q{Add Missing Trips for String([qw(Model.ManualRideListForm RealmOwner.display_name)]);},
	    ADM_FREIKER_CODE_REALLOCATE_FORM => 'Reallocate ZapTags',
	    ADM_FREIKER_CODE_REALLOCATE_CONFIRM => 'Reallocate ZapTags Confirmation',
	    CLUB_PROFILE_FORM => q{School Profile},
	]],
	[clear_on_focus_hint => [
	    GROUP_USER_BULLETIN_LIST_CSV => '',
	]],
	['xhtml.title' => [
	    [qw(FAMILY_FREIKER_RIDE_LIST CLUB_FREIKER_RIDE_LIST)]
		=> 'String([qw(Model.FreikerRideList ->get_display_name)]); Trips',
	    [qw(FAMILY_MANUAL_RIDE_FORM CLUB_MANUAL_RIDE_FORM)]
		=> 'Add Missing Trip for String([qw(Model.FreikerRideList ->get_display_name)]);',
	    [qw(FAMILY_FREIKER_CODE_ADD CLUB_FREIKER_CODE_ADD)]
		=> 'Enter New Boltage Code for String([qw(Model.FreikerRideList ->get_display_name)]);',
	    [qw(FAMILY_FREIKER_EDIT CLUB_FREIKER_EDIT)]
		=> 'Update Info for String([qw(Model.FreikerRideList ->get_display_name)]);',
	    CLUB_FREIKER_MANUAL_RIDE_FORM =>
		'Give trips to String([qw(Model.FreikerRideList ->get_display_name)]);',
	    CLUB_FREIKER_PRIZE_SELECT => q{Select Prize for String([qw(Model.ClubFreikerList RealmOwner.display_name)]); with String([qw(Model.ClubPrizeSelectList ->get_prize_credit)]); credits},
	    FAMILY_PRIZE_PICKUP => 'Where to pickup your prize!',
	]],
	[RealmDropDown => [
	    club => 'School',
	    merchant => 'Merchant',
	]],
	['task_menu.title' => [
	    sort_001 => "\0\1",
	    sort_002 => "\0\2",
	    ADM_RIDE_SUMMARY_LIST => 'All Trip Summary',
	    ADM_SUMMARY_BY_SCHOOL_LIST => 'Trip Summary by School',
	    CLUB_SUMMARY_BY_CLASS_LIST => 'Trip Summary by Class',
	    CLUB_FREIKER_LIST => 'Kids',
	    CLUB_FREIKER_CLASS_LIST => 'Kids',
	    CLUB_FREIKER_CLASS_LIST_FORM => 'Update Kids Classes',
	    CLUB_FREIKER_LIST_CSV => 'Spreadsheet',
	    CLUB_RIDE_DATE_LIST => 'Trips',
	    CLUB_PRIZE => 'Update prize',
	    CLUB_PRIZE_LIST => 'Available prizes',
	    CLUB_REGISTER => 'Register new school',
	    CLUB_SUMMARY_BY_SCHOOL_LIST => 'Trip Summary',
	    CLUB_PROFILE_FORM => 'School Profile',
	    ADM_FREIKER_CODE_REALLOCATE_FORM => 'Reallocate ZapTags',
	    [qw(FAMILY_MANUAL_RIDE_LIST_FORM
		CLUB_MANUAL_RIDE_LIST_FORM)] => 'Add missing trips',
	    [qw(FAMILY_FREIKER_ADD CLUB_FREIKER_ADD)] => 'Register kid',
	    FAMILY_FREIKER_LIST => 'Your family',
	    FAMILY_PRIZE_COUPON_LIST => 'Past prizes',
	    FAMILY_PRIZE_SELECT => 'Choose prize',
	    MERCHANT_PRIZE => 'Add prize',
	    MERCHANT_PRIZE_REDEEM => 'Redeem coupon',
	    MERCHANT_PRIZE_LIST => 'Donated prizes',
	    MERCHANT_REGISTER => 'Register new merchant',
	    PAYPAL_FORM => 'Donate',
	    back_to_family => 'Your family',
	    back_to_club => 'Kids',
	]],
    ],
    b_use('FacadeComponent.Enum')->make_facade_decl([]),
});

1;
