# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SiteAdminDropDown;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put(extra_items => [
	'ADM_FREIKOMETER_LIST',
	'ADM_RIDE_SUMMARY_LIST',
	'CLUB_REGISTER',
	{
	    realm => 'site-contact',
	    task_id => 'FORUM_CRM_THREAD_ROOT_LIST',
	},
    ]);
    return shift->SUPER::initialize(@_);
}

1;
