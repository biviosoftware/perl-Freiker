# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::General;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('IO.Ref');

sub prize_list {
     return shift->internal_body(vs_prize_list('AvailablePrizeList'));
}

sub zap_error_mail {
    return shift->internal_put_base_attr(
	to => Mailbox(vs_constant('site_zap_realm')),
	subject => Join([
	    [qw(Action.FreikometerUpload station_id)],
	    If(['auth_user'],
	       Join([' ', [qw(auth_user name)]])),
	    ' errors',
	]),
	body => Join([
	    [qw(Action.FreikometerUpload errors)],
	    "\n\n",
	    [qw(Action.FreikometerUpload form)],
	]),
    );
}

1;
