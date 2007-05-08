# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::UserAuth;
use strict;
use Bivio::Base 'Bivio::UI::View::UserAuth';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

Freiker, Inc. is finally a 501(c)(3) so donations are tax-deductible.
We have been very successful at increasing ridership in Boulder.  With
success comes increased costs.  Please take a minute to donate:

Link('/hm/donate');

We accept checks and credit cards through PayPal.  You don't have to
register with PayPal, just skip down to "Don't have a PayPal Account?"
It's a very convenient way to donate and to help keep the kids
excited to ride.

100% of our donations by individuals goes towards prizes for the kids.

Thanks for riding,
Rob Nagler
Executive Director
Freiker, Inc.
EOF
    );
    return;
}

sub registration_sent {
    return shift->internal_body(DIV_prose(Prose(<<'EOF')));
We have sent a confirmation email to
String([['->get_by_regexp', 'Model.\w+RegisterForm'], 'Email.email']);.
Please follow the instructions in this email message to complete
your registration with vs_site_name();.
EOF
}

1;
