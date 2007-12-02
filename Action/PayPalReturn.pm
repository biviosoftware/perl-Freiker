# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::PayPalReturn;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my(undef, $req) = @_;
    # PayPal has odd behavior.  Sometimes it has "return to merchant", iwc
    # it returns via a GET on a <FORM>.  Other times, it returns directly
    # to the page.  It seems to be whether it thinks the return URL is legit.
    my($pi, $q) = $req->get(qw(path_info query));
    ($pi, $q) = ($pi || '?') =~ /^(.*?)\?(.*)$/s
	unless $q;
    return $pi ? {
	uri => $pi,
	query => $q,
    } : {
	task_id => 'SITE_ROOT',
	query => $q,
    };
}

sub return_uri {
    my($proto, $form, $ack) = @_;
    my($req) = $form->get_request;
    my($c) = $form->unsafe_get_context;
#TODO: Allow different cancel task
    return $req->format_http({
	task_id => 'PAYPAL_RETURN',
	# PayPal encodes the "return to merchant" link as a GET form,
	# which clears the query so we have to play this trick.
	path_info => $req->format_uri(
	    $c ? {
		task_id => $c->get('unwind_task'),
		map(($_ => $c->get_or_default($_, undef)), qw(realm path_info)),
		query => {
		    %{$c->get('query') || {}},
		    ack => $ack,
		},
	    } : {
		task_id => 'SITE_ROOT',
		query => {
		    ack => $ack,
		},
	    },
	),
    });
}

1;
