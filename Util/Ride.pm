# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Ride;
use strict;
use Bivio::Base 'Bivio.ShellUtil';


sub import_csv {
    my($self) = @_;
    $self->model('RideImportForm')->process_content($self->read_input);
    return;
}

1;
