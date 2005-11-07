# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::Facade::Freiker;
use strict;
$Freiker::Facade::Freiker::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Facade::Freiker::VERSION;

=head1 NAME

Freiker::Facade::Freiker - main production and default facade

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Freiker::Facade::Freiker;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Freiker::Facade::Freiker::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Freiker::Facade::Freiker> is the main production and default Facade.

=cut

#=IMPORTS

#=VARIABLES
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
	}] => []],
    ],
    FormError => [
	[NULL => 'You must supply a value for vs_fe("label");.'],
	['SchoolRegisterForm.School.website.EXISTS' =>
	     q{This school's website is already registered.  Please try to find the "wheel" at your school.}],
	['SchoolRegisterForm.RealmOwner_2.display_name.EXISTS' =>
	     q{Your school is already registered.  Please try to find the "wheel" at your school.}],
	['BarcodeUploadForm.barcode_file.NUMBER_RANGE' =>
	     qq{File errors:\nString(['Model.BarcodeUploadForm', 'file_errors']);}],
	['BarcodeUploadForm.barcode_file.EMPTY' =>
	     q{The file appears to be empty or may contain all duplicate rides.}],
	['FreikerLoginForm.barcode.NOT_FOUND' =>
#TODO: Link to form to contact wheel
	     q{Barcode is not in our database.  Please check and re-enter.  If you are absolutely sure vs_fe('value'); is correct, please contact your school's Wheel.}],
	['FreikerLoginForm.ride_date1.NULL' =>
	     q{You must specify at least one ride.  If you have ridden fewer than three times the whole year, just leave the last one or two entries alone.}],
	['FreikerLoginForm.ride_date1.PASSWORD_MISMATCH' =>
	     q{One or more of the dates did not match our database.  Please check and re-enter.  If you are absolutely sure these dates are correct, please contact your school's Wheel.}],
	[[map("FreikerLoginForm.ride_date$_.PASSWORD_MISMATCH", 2, 3)] =>
	     q{See above}],
	['BarcodeMergeListForm.want_merge.MERGE_OVERLAP' =>
	     q{At least one overlapping ride date (DateTime(['Ride.ride_date']);).  Might be wrong barcodes, or perhaps accidental duplicates.  Click on the barcodes on this line to see the rides, and delete duplicates.}],
    ],
    HTML => [
	[want_secure => 0],
	[table_default_align => 'left'],
    ],
    Task => [
	[CLUB_HOME => '?'],
	[DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef],
	[FAVICON_ICO => '/favicon.ico'],
	[FORBIDDEN => undef],
	[LOCAL_FILE_PLAIN => ['i/*', 'f/*', 'h/*']],
	[LOGIN => 'pub/login'],
	[LOGOUT => 'pub/logout'],
	[MY_SITE => 'my-site/*'],
	[MY_CLUB_SITE => undef],
	[SHELL_UTIL => undef],
	[SITE_ROOT => '/*'],
	[USER_HOME => '?'],
	[SCHOOL_REGISTER => 'pub/register-school'],
	[TEST_BACKDOOR => '_test_backdoor'],
	[WHEEL_CLASS_LIST => '?/classes'],
	[SCHOOL_HOME => undef],
	[CLASS_HOME => undef],
	[SCHOOL_REALMLESS_REDIRECT => 'rs/*'],
	[WHEEL_BARCODE_UPLOAD => '?/upload-barcodes'],
	[WHEEL_BARCODE_LIST => '?/assign-barcodes'],
	[SCHOOL_RANK_LIST => '/pub/schools'],
	[WHEEL_FREIKER_RANK_LIST => '?/freiker-rankings'],
	[WHEEL_USER_PASSWORD => '?/change-password'],
	[USER_REALMLESS_REDIRECT => 'ru/*'],
	[FREIKER_LOGIN => 'pub/freiker-login'],
	[FREIKER_INFO => '?/info'],
	[FREIKER_RIDE_LIST => '?/rides'],
	[WHEEL_BARCODE_MERGE_LIST => '?/merge-barcodes'],
	[WHEEL_BARCODE_RIDE_LIST => '?/freiker-rides'],
        [ROBOTS_TXT => '/robots.txt'],
    ],
    Text => [
	[support_email => 'support'],
#TODO:	    [support_phone => '(800) 555-1212'],
	[site_name => q{Freiker: The Frequent Biker Program}],
	[site_copyright => q{bivio Software, Inc.}],
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
	[zip => 'US ZIP+4'],
	[school_name => 'Official Name'],
	['School.website' => 'Website'],
	[class_size => 'Class Size'],
	['RealmOwner.display_name' => 'Your Name'],
	[SchoolRegisterForm => [
	    'zip.desc' => q{Your school's-9 digit US zip code.},
	    'RealmOwner.display_name.desc'
		=> q{You will be the Wheel for your school.},
	    'Email.email.desc' =>
		q{We will send emails only related to running Freiker at your school.},
	    ok_button => 'Register School',
	]],
	['User.gender' => 'Teacher'],
	['User.first_name' => 'First Name'],
	['User.last_name' => 'Last Name'],
	[class_grade => 'Grade'],
	[ClassListForm => [
	    ok_button => 'Save',
	]],
	[UserLoginForm => [
	    ok_button => 'Login',
	]],
	[link => [
	    LOGIN => 'Already registered?  Click here to login.',
	    SCHOOL_REGISTER => 'Not registered?  Wheels click here to register your school.',
	]],
	[barcode_file => 'Barcode File'],
	[BarcodeUploadForm => [
	    ok_button => 'Upload',
	]],
	[[qw(class_id class_name)] => 'Class'],
	['BarcodeList.RealmOwner.name' => 'Barcode'],
	[BarcodeListForm => [
	    'RealmOwner.display_name' => 'First Name (Last if needed)',
	    ok_button => 'Assign',
	]],
	[separator => [
	    school => 'School Information',
	]],
	[SchoolRankList => [
	    'RealmOwner.display_name' => 'School',
	    'Address.zip' => 'Zip',
	]],
	[FreikerRankList => [
	    'RealmOwner.name' => 'Barcode',
	    'RealmOwner.display_name' => 'Freiker',
	    'ride_count' => 'Rides',
	]],
	[UserPasswordForm => [
	    old_password => 'Current Password',
	    new_password => 'New Password',
	    confirm_new_password => 'Re-enter New Password',
	    ok_button => 'Change',
	]],
	[FreikerLoginForm => [
	    barcode => 'Your Barcode',
	    ride_date1 => 'Most Recent Ride',
	    ride_date2 => 'Ride Before Last',
	    ride_date3 => 'Three Rides Ago',
	    ok_button => 'Login',
	]],
	[[qw(BarcodeMergeList BarcodeMergeListForm)] => [
	    'RealmOwner.name' => 'Original',
	    'RealmOwner.display_name' => 'Freiker',
	    class_name => 'Class',
	    'RealmOwner_2.name' => 'Duplicate',
	    want_merge => 'Merge Barcodes?',
	    ok_button => 'Merge',
	]],
	[[qw(BarcodeRideList BarcodeRideListForm)] => [
	    'Ride.ride_date' => 'Ride Date',
	    want_delete => 'Delete?',
	    ok_button => 'Delete',
	]],
	[FreikerInfoForm => [
	    'RealmOwner.display_name' => [
		'' => 'Your First Name',
		desc => q{If you have a common first name, please include your last name initial, e.g. John Q.},
	    ],
	    'Class.class_id' => 'Your Teacher',
	    ok_button => 'Update',
	]],
	[acknowledgement => [
	    [qw(WHEEL_BARCODE_LIST WHEEL_CLASS_LIST)]
		=> q{Your changes have been saved.},
	    WHEEL_BARCODE_UPLOAD => q{Your upload was successful.},
	    FREIKER_INFO => q{Your information has been updated.  Thank you.},
	    WHEEL_BARCODE_MERGE_LIST => q{The barcodes have been merged.},
	    WHEEL_BARCODE_RIDE_LIST => q{The rides have been deleted.},
	]],
    ],
});

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
