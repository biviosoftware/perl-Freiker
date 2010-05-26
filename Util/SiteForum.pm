# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SiteForum;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');

sub init {
    return shift->call_super_before(\@_, sub {
        my($self) = @_;
	return $self->init_site_zap_realm;
    });
}

sub init_site_zap_realm {
    my($self) = @_;
    my($req) = $self->initialize_ui;
    $req->with_realm($self->SITE_REALM, sub {
	$self->set_user_to_any_online_admin;
        $self->model('ForumForm', {
	    'RealmOwner.display_name' => 'Zap Errors',
	    'RealmOwner.name' => $_C->get_value('site_zap_realm', $req),
	    mail_want_reply_to => 0,
	    mail_send_access => b_use('Type.MailSendAccess')->EVERYBODY,
	});
	return;
    });
    return;
}

1;
