# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::PayPalReturn;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my(undef, $req) = @_;
    # See PayPal form
    my($u, $q) = ($req->get('path_info') || '?') =~ /^(.*?)\?(.*)$/s;
    return {
	uri => $u,
	query => $q,
    };
}

sub return_uri {
    my($proto, $form, $ack) = @_;
    my($req) = $form->get_request;
    my($c) = $form->unsafe_get_context;
#TODO: Special cancel task
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
