# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::PayPalForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_ULF) = __PACKAGE__->get_instance('UserLoginForm');
my($_PPR) = Bivio::Biz::Action->get_instance('PayPalReturn');
my($_QUERY_KEY) = Bivio::Biz::Action->get_instance('Acknowledgement');
$_QUERY_KEY = $_QUERY_KEY->can('QUERY_KEY') ? $_QUERY_KEY->QUERY_KEY
    : 'ack';

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(amount => 50);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    Bivio::IO::Alert->warn(
	'paypal=', $self->get('amount'),
	' user=', $req->unsafe_get('auth_user_id')
	    || $_ULF->unsafe_get_cookie_user_id($req),
    );
    return {
	method => 'client_redirect',
	uri => 'https://www.paypal.com/cgi-bin/webscr',
	query => {
	    cmd => '_xclick',
	    business => 'paypal-donations@freiker.org',
	    item_name => 'Tax-deductible Donation to Freiker: The Frequent Biker Program',
	    amount => $self->get('amount'),
	    no_shipping => 1,
	    no_note => 1,
	    currency_code => 'USD',
	    return => $_PPR->return_uri($self, 'paypal_ok'),
	    cancel_return => $_PPR->return_uri($self, 'paypal_cancel'),
	    bn => 'PP-DonationsBF',
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
        visible => [
	    {
		name => 'amount',
		type => 'Dollars',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_post_execute {
    my($self) = @_;
    my($req) = $self->req;
    $req->put(path_info => 'Donate');
    $self->use('Action.WikiView')->execute_prepare_html(
	$req,
	undef,
	Bivio::Agent::TaskId->FORUM_WIKI_VIEW,
    );
    return;
}

sub internal_pre_execute {
    my($self) = @_;
    my($req) = $self->req;
    $self->throw_die(NOT_FOUND => {
	message => 'Only works in site realm',
	enity => $req->get('auth_id'),
    }) unless b_use('FacadeComponent.Constant')->get_value(site_realm_id => $req)
	eq $req->get('auth_id');
    return;
}

1;
