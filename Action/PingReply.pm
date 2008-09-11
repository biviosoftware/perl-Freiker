# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::PingReply;
use strict;
use Bivio::Base 'Action.EmptyReply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

#BEBOP: 6.84
sub execute {
    my(undef, $req) = @_;
    my($output) = $_DT->now_as_file_name;
    $req->get('reply')->set_output(\$output);
    return shift->SUPER::execute(@_);
}

1;
