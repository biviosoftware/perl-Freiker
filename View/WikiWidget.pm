# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::WikiWidget;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub all_club_summary_list {
    return shift->internal_put_base_attr(
	vs_freiker_list_selector([qw(fr_begin fr_end fr_all)]),
	body => vs_list(AllClubSummaryList => [
	    {
		field => 'RealmOwner.display_name',
		column_data_class => 'school',
	    },
	    map(
		+{
		    field => $_,
		    $_ ne 'days_10000' ? ()
			: (column_control => ['Model.AllClubSummaryList', '->show_all']),
		    column_widget => SPAN(
			AmountCell([$_], {decimals => 0}),
			{
			    class => [sub {
				my(undef, $rank) = @_;
				return ($rank <= 3 ? "rank_$rank" : '');
			    }, ["rank_$_"]],
			},
		    ),
		    column_data_class => 'amount_cell',
		},
		qw(days_1 days_5 days_20 days_10000),
	    ),
	], {
	    heading_row_class => 'heading',
	    class => 'ride_summary list',
	}),
    );
}

1;
