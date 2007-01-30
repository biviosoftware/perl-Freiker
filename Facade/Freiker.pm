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
	[[qw(
	    table_separator
	    table_odd_row_bg
	    table_even_row_bg
	    page_alink
	    page_link
	    page_link_hover
	    page_bg
	    page_text
	    page_vlink
	    summary_line
	    error
	    warning
 	)] => -1],
    ],
    Font => [
	map([$_->[0] => [qq{class=$_->[1]}]],
	    [[qw(error form_field_error form_field_error_label)] => 'err'],
	    [warning => 'warn'],
	    [checkbox => 'checkbox'],
	    [form_submit => 'button'],
	    [form_field_label => 'ok'],
	),
	[[qw{
	    default
	    ch
	    input_field
	    mailto
	    number_cell
	    page_heading
	    page_text
	    radio
	    search_field
	    table_cell
	    table_heading
	    list_action
	}] => []],
    ],
    FormError => [
	[NULL => 'You must supply a value for vs_fe("label");.'],
	[NUMBER => 'Please enter a number'],
	['PayPalForm.amount.NULL' => 'Any amount will do!'],
	[EXISTS => 'vs_fe("label"); already exists in our database.'],
	[NOT_FOUND => 'vs_fe("label"); was not found in our database.'],
	['FreikerForm.FreikerCode.freiker_code' => [
	    NOT_FOUND => 'This is not a valid vs_fe(q{label}); for your school.  Please check the number and resubmit.',
	    EXISTS => 'The vs_fe(q{label}); has not been scanned by the Freikometer yet.',
	]],
	['ClubRegisterForm.ClubAux.website.EXISTS' => q{This school's website is already registered.  Please try to find the "wheel" at your school.}],
	['ClubRegisterForm.club_name.EXISTS' => q{Your school is already registered.  Please try to find the "wheel" at your school.}],
	['email.EXISTS' => q{This email is already registered with vs_site_name();.  Link('Click here to login.', 'LOGIN', {no_context => 1});}],
	['Ride.ride_date.NOT_FOUND' => q{This date was not a school day.}],
	['Ride.ride_date.EXISTS' => q{The Freiker was already credited for his date.  Please enter a different date.}],
    ],
    HTML => [
	[want_secure => 0],
	[table_default_align => 'left'],
    ],
    Constant => [
	[xlink_paypal => {
	    uri => 'http://www.paypal.com/us',
	}],
    ],
    Task => [
	[CLUB_HOME => '?'],
	[CLUB_REGISTER => 'pub/register-organization'],
	[CLUB_REGISTER_DONE => undef],
	[CLUB_FREIKER_LIST => '?/freikers'],
	[DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef],
	[FAMILY_REGISTER => 'pub/register-family'],
	[FAMILY_REGISTER_DONE => undef],
	[FAMILY_FREIKER_ADD => '?/register-freiker'],
	[FAMILY_FREIKER_LIST => '?/freikers'],
	[FAMILY_FREIKER_RIDE_LIST => '?/rides'],
        [FAMILY_MANUAL_RIDE_FORM => '?/add-ride'],
	[FAVICON_ICO => '/favicon.ico'],
	[FORBIDDEN => undef],
	[GENERAL_USER_PASSWORD_QUERY => '/pub/forgot-password'],
	[GENERAL_USER_PASSWORD_QUERY_ACK => undef],
	[GENERAL_USER_PASSWORD_QUERY_MAIL => undef],
	[LOCAL_FILE_PLAIN => ['i/*', 'f/*', 'h/*', 'm/*']],
	[LOGIN => 'pub/login'],
	[LOGOUT => 'pub/logout'],
#	[MY_CLUB_SITE => 'my-school/*'],
	[MY_CLUB_SITE => undef],
	[MY_SITE => 'my-site/*'],
	[SHELL_UTIL => undef],
	[SITE_DONATE => 'hm/donate'],
	[SITE_PARENTS => 'hm/parents'],
	[SITE_PRESS => 'hm/press'],
	[SITE_PRIZES => 'hm/prizes'],
	[SITE_ROOT => '/*'],
	[SITE_SPONSORS => 'hm/sponsors', 'hm/gears'],
	[SITE_WHEELS => '/hm/wheels'],
	[TEST_BACKDOOR => '_test_backdoor'],
	[USER_HOME => '?'],
	[USER_PASSWORD => '?/change-password'],
	[USER_PASSWORD_RESET => '?/new-password'],
	[USER_REALMLESS_REDIRECT => 'ru/*'],
        [PAYPAL_RETURN => 'pp/*'],
        [ROBOTS_TXT => 'robots.txt'],
        [FREIKOMETER_UPLOAD => '_fm_upload'],
    ],
    Text => [
	[support_email => 'gears'],
	[contact_email => 'gears'],
#TODO:	    [support_phone => '(800) 555-1212'],
	[site_name => q{Freiker}],
	[site_copyright => q{Freiker, Inc.}],
	[home_page_uri => '/hm/index'],
	[view_execute_uri_prefix => 'site_root/'],
	[favicon_uri => '/i/favicon.ico'],
	[form_error_title => 'Please correct the errors below:'],
	[none => ''],
	[Image_alt => [
	    [qw(dot heart_14 heart heart_9)] => '',
	    at => 'at sign image to help avoid spam',
	    bivio_power => 'Operated by bivio Software, Inc.',
	    [qw(smiley smiley_80)] => 'Freiker: The Frequent Biker Program',
	]],
	[ok_button => '   OK   '],
	[cancel_button => ' Cancel '],
	[password => 'Password'],
	[confirm_password => 'Re-enter Password'],
	[['email', 'login'] => 'Your Email'],
	[club_name => 'Official Name'],
	[[qw(paged_detail paged_list)] => [
	    prev => 'Back',
	    next => 'Next',
	    list => 'Back to list',
	]],
	[Ride => [
	    ride_date => 'Date',
	]],
	['Address.zip.desc' =>
	     q{A 9-digit US zip code is required.  Link('Look up at the US Postal service website', 'http://zip4.usps.com/zip4/welcome.jsp', {link_target => '_blank'});, if you don't know it},],
	[ClubRegisterForm => [
	    'ClubAux.club_size' => 'Number of Students',
	    'ClubAux.club_size.desc' => 'Total number of students including freikers and non-freikers.',
	    'ClubAux.website' => 'School Website',
	    'ClubAux.website.desc' => 'Example: http://schools.bvsd.org/crestview/index.html',
	    'Address.zip' => 'US ZIP+4',
	    'RealmOwner.display_name' => 'Your Name',
	    'Email.email.desc' =>
		q{We will send emails only related to running Freiker.},
	    ok_button => 'Register School',
	]],
	[UserRegisterForm => [
	    'RealmOwner.display_name' => 'Your Family (Last) Name',
	    'RealmOwner.display_name.desc' => 'You need not supply a real name here, since we will not be contacting you except by email.',
	    'Address.zip' => 'Your ZIP+4 Code',
	    ok_button => 'Register Family',
	]],
	[FreikerForm => [
	    'User.first_name' => q{First Name},
	    'User.first_name.desc' => q{This is for your information only so it may be a nickname, an abbreviation, or any other identifier.},
	    'Club.club_id' => q{School},
	    'FreikerCode.freiker_code' => q{Freiker ID},
	    'FreikerCode.freiker_code.desc' => q{The number on your child's helmet.},
	    'birth_year' => q{Year of Birth},
	    'User.gender' => q{Gender},
	    ok_button => 'Register Child',
	]],
	[ManualRideForm => [
	    'Ride.ride_date' => q{Date Missing},
	    ok_button => 'Add Ride',
	    prose => [
		prologue => <<'EOF',
We allow a certain number of missed rides as a courtesy to parents.
When there are too many missed rides, this list will no longer show.
Please enter the date of the missing ride for
String([qw(Model.FreikerList RealmOwner.display_name)]);.
EOF
	    ],
	]],
	[UserLoginForm => [
	    ok_button => 'Login',
	]],
	[separator => [
	    optional => 'Optional information used for statistical purposes',
	    club => 'School Information',
	]],
	[[qw(FreikerList ClubFreikerList)] => [
	    'RealmOwner.display_name' => 'Freiker',
	    ride_count => 'Rides',
	    empty_list_prose => 'No Freikers as yet.',
	    list_actions => 'Actions',
	    list_action => [
		FAMILY_FREIKER_RIDE_LIST => 'Show Rides',
		FAMILY_MANUAL_RIDE_FORM => 'Add Missing Ride',
	    ],
	]],
	[UserPasswordForm => [
	    old_password => 'Current Password',
	    new_password => 'New Password',
	    confirm_new_password => 'Re-enter New Password',
	    ok_button => 'Update',
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
	['UserPasswordQueryForm.ok_button' => 'Send'],
	[prose => [
	    LOGIN => q{Already registered?  Link('Click here to login.', {task_id => 'LOGIN', no_context => 1});},
	    FAMILY_REGISTER => q{Child not registered?  vs_link('Click here to register your family.', 'FAMILY_REGISTER');},
	    CLUB_REGISTER => q{Would you like to become a wheel? vs_link('Click here to register your school.', 'CLUB_REGISTER');},
	    GENERAL_USER_PASSWORD_QUERY => q{Forgot your password? Link('Click here to get a new one.', 'GENERAL_USER_PASSWORD_QUERY');},
	]],
	[acknowledgement => [
            GENERAL_CONTACT => 'Your inquiry has been sent.  Thank you!',
	    FAMILY_FREIKER_ADD => q{Your child has been added.},
	    FAMILY_MANUAL_RIDE_FORM => q{The missing date has been added.},
	    GENERAL_USER_PASSWORD_QUERY => <<'EOF',
An email has been sent to
String([qw(Model.UserPasswordQueryForm Email.email)]);.
The email contains a link back to this site so
you can reset your password.
EOF
	    USER_PASSWORD => q{Your password has been changed.},
	    password_nak => q{We're sorry, but the link you clicked on is no longer valid.  Please enter your email address and send again.},
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
	]],
	['page3.title' => [
	    CLUB_FREIKER_LIST => "Your School's Freikers",
	    CLUB_REGISTER => 'Register Your School',
	    FAMILY_FREIKER_ADD => 'Register Your Child',
	    FAMILY_FREIKER_LIST => "Your Family's Freikers",
	    FAMILY_REGISTER => 'Register Your Family',
	    LOGIN => 'Please Login',
	    USER_PASSWORD => 'Change Your Password',
	    [qw(CLUB_REGISTER_DONE FAMILY_REGISTER_DONE GENERAL_USER_PASSWORD_QUERY)] => 'Check Your Mail',
	    SITE_ROOT => 'The Frequent Biker Program',
	    [qw(SITE_SPONSORS SITE_DONATE)] => 'We need your help!',
	    SITE_PARENTS => 'For parents',
	    SITE_PRESS => 'In the news',
	    SITE_PRIZES => 'Ride and win!',
	    SITE_WHEELS => 'Wheels roll around',
	    FAMILY_FREIKER_RIDE_LIST =>
		'String([qw(Model.FreikerRideList ->get_display_name)]); Rides',
	    FAMILY_MANUAL_RIDE_FORM =>
		'Add Missing Ride for String([qw(Model.FreikerRideList ->get_display_name)]);',
	]],
	['task_menu.title' => [
	    LOGIN => 'Login',
	    FAMILY_REGISTER => 'Register',
	    USER_PASSWORD => 'Account',
	    FAMILY_FREIKER_LIST => 'Family',
	    FAMILY_FREIKER_ADD => 'Register Child',
	    CLUB_FREIKER_LIST => 'School',
	    SITE_ROOT => 'Home',
	    SITE_SPONSORS => 'Sponsors',
	    SITE_DONATE => 'Donate',
	    SITE_PARENTS => 'Parents',
	    SITE_PRESS => 'Press',
	    SITE_PRIZES => 'Prizes',
	    SITE_WHEELS => 'Wheels',
	    FAMILY_MANUAL_RIDE_FORM => 'Add Missing Ride',
	]],
    ],
});

1;
