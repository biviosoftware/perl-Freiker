# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::UserAuth;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    return shift->internal_body(vs_simple_form(UserRegisterForm => [
	qw{
	   UserRegisterForm.RealmOwner.display_name
	   UserRegisterForm.Email.email
	   UserRegisterForm.Address.zip
	   UserRegisterForm.Address.country
        },
    ]));
}

sub create_mail {
    view_put(
	mail_to => Mailbox([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']),
	mail_recipients => Mailbox([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']),
	mail_subject => Join([vs_site_name(), ' Registration Verification']),
	mail_body => Prose(<<'EOF'),
Thank you for registering with vs_site_name();.  In order to
complete your registration, please click on the following link:

String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'uri']);

String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']); is the email address we have for you in our database.
You will use this address to login along with the password you
will set when you click on the above link.

Thanks for registering.  Every Trip Counts!TM

Freiker, Inc.
Link('SITE_ROOT');

Freiker, Inc. (EIN 56-2539016) is a tax-exempt organization under Section
501(c)3 of the Internal Revenue Code. Your donation is tax deductible to the
full extent of the law.  Just $10 will help:
Freiker, Inc. (EIN 56-2539016) is a tax-exempt organization under
Section 501(c)(3) of the Internal Revenue Code. Your donation is tax
deductible to the full extent of the law - Link('/site/donate');

EOF
    );
    return;
}

sub internal_settings_form_extra_fields {
    return [qw(
        UserSettingsListForm.Address.zip
        UserSettingsListForm.Address.country
    )];
}

1;
