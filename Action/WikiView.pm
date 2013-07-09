# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::WikiView;
use strict;
use Bivio::Base 'Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_V) = b_use('UI.View');
my($_C) = b_use('FacadeComponent.Constant');

sub execute_task_item {
    my($proto, $method, $req) = @_;
    return $proto->$method($req)
#TODO: Get the value of FORUM_WIKI_VIEW's uri.  If GENERAL, then SITE_WIKI_VIEW
	unless $method =~ s/^bp_//s;
    return $proto->execute_prepare_html(
	$req,
#TODO: Encapsulate in prepare_html, because never would load GENERAL's WIKI
	$req->get('auth_realm')->is_general
	    ? $_C->get_value('site_realm_id', $req) : undef,
	undef,
	$method,
    ) || $_V->execute('Wiki->view', $req);
}

1;
