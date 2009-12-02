# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Btest;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub read_log {
    my($self, $path) = @_;
    $self->initialize_fully;
    $self->req->assert_test;
    return b_use('IO.Log')->read($path, $self->req);
}

sub write_log {
    my($self, $path, $contents) = @_;
    $self->initialize_fully;
    $self->req->assert_test;
    return b_use('IO.Log')->write($path, $contents, $self->req);
}

1;
