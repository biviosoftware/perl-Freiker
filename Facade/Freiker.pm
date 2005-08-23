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
# I think I should do css.
# All names map to classes.
# Make forms look like Oxford.
	[[qw(base_heading page_link page_vlink page_alink)] => 0x33cc00],
	[page_link_hover => 0x99ff33],
	[page_text => 0],
	[page_bg => 0xFFFFFF],
	[page_heading => -1],
	[error => 0x990000],
	[warning => 0x990001],
	[table_heading => -1],
	[table_even_row_bg => 0xF3F3F3],
	[table_odd_row_bg => -1],
	[table_separator => 0],
	[summary_line => 0x66CC66],
    ],
    Font => [
	[default => [
	    'family=verdana,arial,helvetica,geneva,sunsans-regular,sans-serif',
	    'size=small',
	]],
	[error => ['color=error', 'bold']],
	[form_field_error => ['color=error', 'smaller', 'bold']],
	[form_field_error_label => ['color=error', 'italic']],
	[page_heading => ['bold']],
	[table_heading => ['color=table_heading', 'bold']],
	[warning => ['color=warning', 'bold']],
	[[qw(
		checkbox
		form_field_label
		form_field_description
		form_submit
		input_field
		mailto
		number_cell
		page_text
		radio
		search_field
		table_cell
	)] => []],

	# Add your own here
	[text_button => ['larger']],
	[base_heading => ['size=x-large']],
    ],
    FormError => [
	[NULL => 'You must supply a value for vs_fe("label");.'],
	['SchoolRegisterForm.School.website.EXISTS' =>
	     q{This school's website is already registered.  Please try to find the "wheel" at your school.}],
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
	[LOCAL_FILE_PLAIN => ['/i/*']],
	[LOGIN => undef],
#TODO:	    [LOGOUT => 'pub/logout'],
	[MY_SITE => undef],
	[MY_CLUB_SITE => undef],
	[SHELL_UTIL => undef],
	[SITE_ROOT => '/*'],
	[USER_HOME => '?'],
	[SCHOOL_REGISTER => '/pub/register-school'],
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
	    dot => '',
	    bivio_power => 'Operated by bivio Software, Inc.',
	    [qw(smiley smiley_80)] => 'Freiker: The Frequent Biker Program',
	]],
	[ok_button => '   OK   '],
	[cancel_button => ' Cancel '],
	[password => 'Password'],
	[confirm_password => 'Re-enter Password'],
	['email', 'login' => 'Your Email'],
	[zip => '9 Digit Zip'],
	[SchoolRegisterForm => [
	    'RealmOwner.display_name' => 'Your Name',
	    'RealmOwner_2.display_name' => 'School Name',
	    'School.website' => 'School Website',
	    ok_button => 'Register Your School',
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
