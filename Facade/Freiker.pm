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
	[default => []],
	map([$_ => [qq{class=$_}]], qw{
	    checkbox
	    error
	    form_field_checkbox
	    form_field_description
	    form_field_error
	    form_field_error_label
	    form_field_label
	    form_submit
	    input_field
	    mailto
	    number_cell
	    page_heading
	    page_text
	    radio
	    realm_name
	    search_field
	    table_cell
	    table_heading
	    warning
	}),
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
	[MY_SITE => 'my-site'],
	[MY_CLUB_SITE => undef],
	[SHELL_UTIL => undef],
	[SITE_ROOT => '/*'],
	[USER_HOME => '?'],
	[SCHOOL_REGISTER => 'pub/register-school'],
	[TEST_SCHOOL_DELETE => '_test/delete-school'],
	[WHEEL_CLASS_LIST => '?/classes'],
	[SCHOOL_HOME => undef],
	[CLASS_HOME => undef],
	[SCHOOL_REALMLESS_REDIRECT => 'rs/*'],
	[WHEEL_BARCODE_UPLOAD => '?/upload-barcodes'],
	[WHEEL_BARCODE_LIST => '?/assign-barcodes'],
	[SCHOOL_RANK_LIST => '/pub/schools'],
	[WHEEL_FREIKER_RANK_LIST => '?/freiker-rankings'],
	[USER_PASSWORD => '?/change-password'],
	[USER_REALMLESS_REDIRECT => 'ru/*'],
    ],
    Text => [
	[support_email => 'support'],
#TODO:	    [support_phone => '(800) 555-1212'],
	[site_name => q{Freiker: The Frequent Biker Program}],
	[home_page_uri => '/hm/index'],
	[view_execute_uri_prefix => 'site_root/'],
	[favicon_uri => '/i/favicon.ico'],
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
	    ok_button => 'Register School',
	]],
	['User.gender' => 'Teacher'],
	['User.first_name' => 'First Name'],
	['User.last_name' => 'Last Name'],
	[class_grade => 'Grade'],
	[ClassListForm => [
	    commit_and_add_rows => 'Add More Teachers',
	    ok_button => 'Update',
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
	[class_id => 'Class'],
	['BarcodeList.RealmOwner.name' => 'Barcode'],
	[BarcodeListForm => [
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
	    'ride_count' => 'Rides',
	]],
	[UserPasswordForm => [
	    old_password => 'Current Password',
	    new_password => 'New Password',
	    confirm_new_password => 'Re-enter New Password',
	    ok_button => 'Change',
	]],
	map({
	    my($t, $v) = @$_;
	    map(["$_->[0].$t" => $_->[1]], @$v);
	}
	   [field_description => [
	       ['SchoolRegisterForm.zip' =>
		    q{Your school's-9 digit US zip code.}],
	       ['SchoolRegisterForm.RealmOwner.display_name'
		    => q{You will be the Wheel for your school.}],
	       ['SchoolRegisterForm.Email.email'
		    => q{We will send emails only related to running Freiker at your school.}],
	   ]],
	),
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
