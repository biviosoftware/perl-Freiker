# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ContactForm;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

#TODO: Remove 1/15/08
sub execute_ok {
    my($self) = @_;
    Bivio::UI::View->execute(
	Bivio::IO::Config->if_version(
	    3 => sub {'UserAuth->general_contact_mail'},
	    sub {'contact-mail'},
	),
	$self->req,
    );
    return;
}

1;
