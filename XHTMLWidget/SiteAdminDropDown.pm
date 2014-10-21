# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::SiteAdminDropDown;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    $self->put(extra_items => [
	'ADM_FREIKOMETER_LIST',
	'ADM_SUMMARY_BY_SCHOOL_LIST',
	'ADM_FREIKER_CODE_REALLOCATE_FORM',
	'CLUB_REGISTER',
	{
	    realm => vs_constant('site_admin_realm_name'),
	    task_id => 'GROUP_USER_BULLETIN_LIST_CSV',
	},
	{
	    realm => vs_constant('site_contact_realm_name'),
	    task_id => 'FORUM_CRM_THREAD_ROOT_LIST',
	},
    ]);
    return shift->SUPER::initialize(@_);
}

1;
