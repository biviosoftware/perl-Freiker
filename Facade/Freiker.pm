# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Facade::Freiker;
use strict;
use base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    uri => 'freiker',
    http_host => 'www.freiker.org',
    mail_host => 'freiker.org',
    Color => [
	[footer_border_top => 0x0],
	[[qw(a_link left_login_background notice h3)] => 0x33CC00],
	[[qw(acknowledgement_border a_hover a_hover_img_border)] => 0x99FF33],
	[[qw(title topic header_realm header_menu_border_bottom line_border_top)] => 0x666666],
	[[qw(err warn empty_list_border)] => 0xcc0000],
	[a_img_border => 0xFFFFFF],
	[main_left_text => 0xFFFFFF],
    ],
    Font => [
	[a_link => 'normal'],
	[a_hover => 'underline'],
	[user_state => ['larger', 'uppercase', 'bold']],
	[body => ['family=Verdana, Arial, Helvetica, Geneva, SunSans-Regular, sans-serif', 'small']],
	[highlight => 'bold'],
	[pending_upload => ['italic', 'uppercase']],
	[user_state => ['150%', 'uppercase', 'bold']],
	[footer => []],
	[topic => [qw(150% bold)]],
	[header_menu => '150%'],
    ],
    FormError => [
	[NUMBER => 'Please enter a number'],
	['PayPalForm.amount.NULL' => 'Any amount will do!'],
	['FreikerCode.freiker_code' => [
	    NOT_FOUND => 'This is not a valid vs_fe(q{label}); for your school.  Please check the number and resubmit.',
	    EXISTS => 'The vs_fe(q{label}); has not been scanned by the Freikometer yet, or the vs_fe(q{label}); is already assigned to a Freiker.  Please verify the number and retry.',
	    MUTUALLY_EXCLUSIVE => q{The vs_fe(q{label}); was scanned on a date your child rode with his old vs_fe(q{label});.  This may not be the right number.  If you are sure the number is correct, vs_wheel_contact();.},
	]],
	['ClubRegisterForm.ClubAux.website.EXISTS' => q{This school's website is already registered.  Please try to find the "wheel" at your school.}],
	['ClubRegisterForm.club_name.EXISTS' => q{Your school is already registered.  Please try to find the "wheel" at your school.}],
	['email.EXISTS' => q{This email is already registered with vs_site_name();.  Link('Click here to login.', 'LOGIN', {no_context => 1});}],
	['Ride.ride_date.NOT_FOUND' => q{This date was not a school day.}],
	['Ride.ride_date.EXISTS' => q{The Freiker was already credited for this date.  Please enter a different date.}],
    ],
    Constant => [
	[xlink_paypal => {
	    uri => 'http://www.paypal.com/us',
	}],
    ],
    Task => [
	[FORUM_CSS => undef],
	[CLUB_REGISTER => '?/register-organization'],
	[CLUB_FREIKER_LIST => '?/freikers'],
	[FAMILY_FREIKER_ADD => '?/register-freiker'],
	[FAMILY_FREIKER_LIST => '?/freikers'],
	[FAMILY_FREIKER_RIDE_LIST => '?/rides'],
        [FAMILY_MANUAL_RIDE_FORM => '?/add-ride'],
        [FAMILY_FREIKER_CODE_ADD => '?/add-tag'],
	[FAVICON_ICO => '/favicon.ico'],
	[LOCAL_FILE_PLAIN => ['i/*', 'f/*', 'h/*', 'm/*']],
	[SITE_DONATE => 'hm/donate'],
	[SITE_ROOT => '/*'],
	[USER_REALMLESS_REDIRECT => 'ru/*'],
        [PAYPAL_RETURN => 'pp/*'],
        [FREIKOMETER_UPLOAD => '_fm_upload'],
    ],
    Text => [
	[support_email => 'gears'],
	[contact_email => 'gears'],
#TODO:	    [support_phone => '(800) 555-1212'],
	[site_name => q{Freiker}],
	[site_copyright => q{Freiker, Inc.}],
	[home_page_uri => '/hm/index'],
	[Image_alt => [
	    at => 'at sign image to help avoid spam',
	    bivio_power => 'Operated by bivio Software, Inc.',
	    [qw(smiley smiley_80)] => 'Freiker: The Frequent Biker Program',
	]],
	[['email', 'login'] => 'Your Email'],
	[club_name => 'Official Name'],
	['FreikerCode.freiker_code' => q{Freiker ID}],
	[Ride => [
	    ride_date => 'Date',
	]],
	['Address.zip.desc' =>
	     q{A 9-digit US zip code is required.  Link('Look it up at the USPS.', 'http://zip4.usps.com/zip4/welcome.jsp', {link_target => '_blank'});},
        ],
	[ClubRegisterForm => [
	    'ClubAux.club_size' => 'Number of Students',
	    'ClubAux.club_size.desc' => 'Total number of students including freikers and non-freikers.',
	    'ClubAux.website' => 'School Website',
	    'ClubAux.website.desc' => 'Example: http://schools.bvsd.org/crestview/index.html',
	    'Address.zip' => 'US ZIP+4',
	    'Email.email.desc' =>
		q{We only send emails related to Freiker.},
	    ok_button => 'Register School',
	]],
	[UserLoginForm => [
	    prose => [
		prologue => q{vs_text_as_prose('USER_CREATE');},
		epilogue => q{vs_text_as_prose('GENERAL_USER_PASSWORD_QUERY');},
	    ],
	]],
	[UserRegisterForm => [
	    prose => [
		prologue => q{In order to better serve you, we validate all email addresses.  When you click Register, we'll email a link which will you to set your password.},
		epilogue => q{vs_text_as_prose('LOGIN');},
	    ],
	    'RealmOwner.display_name' => 'Your Name',
	    'Address.zip' => 'Your ZIP+4 Code',
	    ok_button => 'Register',
	]],
	[FreikerForm => [
	    'User.first_name' => q{First Name},
	    'User.first_name.desc' => q{This is for your information only so it may be a nickname, an abbreviation, or any other identifier.},
	    'Club.club_id' => q{School},
	    'FreikerCode.freiker_code.desc' => q{The number on your child's helmet.},
	    'birth_year' => q{Year of Birth},
	    'User.gender' => q{Gender},
	    ok_button => 'Register Child',
	]],
	[FreikerCodeForm => [
	    prose => [
		prologue => q{Enter the new Freiker ID from the tag on your child's helmet.  If the tag is missing from your child's helmet or you need another tag for a new helmet, vs_wheel_contact();.},
	    ],
	    ok_button => 'Add Tag',
	]],
	[ManualRideForm => [
	    'Ride.ride_date' => q{Date Missing},
	    ok_button => 'Add Ride',
	    prose => [
		prologue => <<'EOF',
We allow a certain number of missed rides as a courtesy to parents.
When there are too many missed rides, this list will no longer show.
Please enter the date of the missing ride for
String([qw(Model.FreikerRideList ->get_display_name)]);.
EOF
	    ],
	]],
	[separator => [
	    optional => 'Optional information used for statistical purposes',
	]],
	[[qw(FreikerList ClubFreikerList)] => [
	    'RealmOwner.display_name' => 'Freiker',
	    ride_count => 'Rides',
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
	[UserPasswordQueryForm => [
	    'prose.prologue' => q{P_prose('Please enter the email address you used to register and click Send.  You will receive an email with a link to reset your password.');},
	    ok_button => 'Send',
	]],
	[prose => [
	    LOGIN => q{Already registered?  Link('Click here to login.', {task_id => 'LOGIN', no_context => 1});},
	    USER_CREATE => q{Child not registered?  vs_link('Click here to register.', 'USER_CREATE');},
	    CLUB_REGISTER => q{Would you like to become a wheel? vs_link('Click here to register your school.', 'CLUB_REGISTER');},
	    GENERAL_USER_PASSWORD_QUERY => q{Forgot your password? Link('Click here to get a new one.', 'GENERAL_USER_PASSWORD_QUERY');},
	]],
	[acknowledgement => [
	    CLUB_REGISTER => q{Your school has been registered.},
	    FAMILY_FREIKER_ADD => q{Your child has been added.},
	    FAMILY_MANUAL_RIDE_FORM => q{The missing date has been added.},
	    FAMILY_FREIKER_CODE_ADD => q{The new Freiker ID was added.},
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
	    paypal_cancel => q{Your donation has been cancelled.  Please consider donating in the future.}
	]],
	[xlink => [
	    paypal => 'PayPal',
	    login_no_context => 'Login',
	    user_create_no_context => 'Register',
	]],
	[FAMILY_FREIKER_RIDE_LIST => 'Show Rides'],
	[FAMILY_MANUAL_RIDE_FORM => 'Add Missing Ride'],
	[FAMILY_FREIKER_CODE_ADD => 'New Helmet Tag'],
	[SiteRoot => [
	    hm_wheels => 'Wheels',
	    hm_sponsors => 'Sponsors',
	    hm_parents => 'Parents',
	    hm_press => 'Press',
	    hm_prizes => 'Prizes',
	]],
	['xhtml.title' => [
	    CLUB_FREIKER_LIST => "Your School's Freikers",
	    CLUB_REGISTER => 'Register Your School',
	    FAMILY_FREIKER_ADD => 'Register Your Child',
	    FAMILY_FREIKER_LIST => "Your Freikers",
	    USER_CREATE => 'Please Register',
	    LOGIN => 'Please Login',
	    ADM_SUBSTITUTE_USER => 'Act as User',
	    USER_PASSWORD => 'Change Your Password',
	    [qw(USER_CREATE_DONE GENERAL_USER_PASSWORD_QUERY)] => 'Check Your Mail',
	    SITE_ROOT => 'The Frequent Biker Program',
	    SITE_DONATE => 'We need your help!',
	    FAMILY_FREIKER_RIDE_LIST =>
		'String([qw(Model.FreikerRideList ->get_display_name)]); Rides',
	    FAMILY_MANUAL_RIDE_FORM =>
		'Add Missing Ride for String([qw(Model.FreikerRideList ->get_display_name)]);',
	    FAMILY_FREIKER_CODE_ADD =>
		'Enter New Freiker ID for String([qw(Model.FreikerRideList ->get_display_name)]);',
	]],
	['task_menu.title' => [
	    CLUB_REGISTER => 'Register School',
	    LOGIN => 'Login',
	    USER_CREATE => 'Register',
	    USER_PASSWORD => 'Account',
	    FAMILY_FREIKER_LIST => q{Your Family},
	    FAMILY_FREIKER_ADD => 'Register Child',
	    SITE_ROOT => 'Home',
	    SITE_DONATE => 'Donate',
	    back_to_family => 'Your Family',
	    back_to_school => 'School',
	]],
    ],
});

1;
