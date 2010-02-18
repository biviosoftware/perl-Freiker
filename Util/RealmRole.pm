# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::RealmRole;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub make_super_user {
    my($self) = @_;
    $self->initialize_fully;
    $self->new_other('Freikometer')->do_all(
	sub {$self->new_other('Freikometer')->join_user_as_member},
    );
    return shift->SUPER::make_super_user(@_);
}

sub unmake_super_user {
    my($self) = @_;
    $self->initialize_fully;
    $self->new_other('Freikometer')->do_all(
	sub {$self->new_other('RealmAdmin')->leave_user},
    );
    return shift->SUPER::unmake_super_user(@_);
}

1;
