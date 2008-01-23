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
	   -optional
	   UserRegisterForm.Address.zip
        },
    ]));
}

sub create_mail {
    view_put(
	mail_to => Mailbox([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']),
	mail_recipients => Join([
	    Mailbox([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']),
	    Mailbox(vs_text('support_email')),
	], ','),
	mail_subject => Join([vs_site_name(), ' Registration Verification']),
	mail_body => Prose(<<'EOF'),
Thank you for registering with vs_site_name();.  In order to
complete your registration, please click on the following link:

String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'uri']);

String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']); is the email address we have for you in our database.
You will use this address to login along with the password you
will set when you click on the above link.

Freiker, Inc. (EIN 56-2539016) is finally a 501(c)(3) so donations are
tax-deductible.  Just $10 will help:

Link('/site/donate');

100% of our donations by individuals go towards prizes for the kids.

Thanks for riding,
Zach Noffsinger
Executive Director
Freiker, Inc.
Saving our society, one bike ride at a time.(tm)
EOF
    );
    return;
}

1;
