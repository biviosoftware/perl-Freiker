# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::GroupUserQueryForm;
use strict;
use Bivio::Base 'Model';


sub internal_roles {
    return [grep(
	$_->equals_by_name(qw(
	    USER
	    MEMBER
	    GUEST
	    ADMINISTRATOR
	    UNAPPROVED_APPLICANT
        )),
	@{shift->SUPER::internal_roles(@_)},
    )];
}

1;
