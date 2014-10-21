# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::ClientRedirect;
use strict;
use Bivio::Base 'Action';


sub uri_parameters {
    my($proto, $uri) = @_;
    return {
	task_id => 'CLIENT_REDIRECT',
	carry_query => 0,
	carry_path_info => 0,
	query => {
	    $proto->QUERY_TAG => $uri,
	},
    };
}

1;
