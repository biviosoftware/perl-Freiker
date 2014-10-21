# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::XHTMLWidget::FeatureTaskMenu;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub internal_selected_item_map {
    return [
	qr{^FAMILY_*} => 'FAMILY_FREIKER_LIST',
	qr{^CLUB_*} => 'CLUB_FREIKER_LIST',
	@{shift->SUPER::internal_selected_item_map(@_)},
    ];
}
sub internal_tasks {
    return [
	{
	    task_id => 'FAMILY_FREIKER_LIST',
	    sort_label => 'sort_001',
	},
	{
	    task_id => 'CLUB_FREIKER_LIST',
	    sort_label => 'sort_002',
	},
	'GENERAL_CONTACT',
	grep(
	    !(ref($_) && ($_->{task_id} || '') eq 'SITE_WIKI_VIEW'),
	    @{shift->SUPER::internal_tasks(@_)},
	),
    ];
}

1;
