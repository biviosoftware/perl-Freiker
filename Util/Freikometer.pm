# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Freikometer;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: fr-freikometer [options] command [args..]
commands
  create name -- creates freikometer in realm
EOF
}

sub create {
    my($self, $name) = @_;
    my($req) = $self->initialize_fully;
    $self->usage_error('name must begin with fm_')
	unless $name =~ /^fm_\w+$/;
    $self->usage_error('you must set a club with -realm')
	unless $req->get_nested(qw(auth_realm type))->eq_club;
    my($p) = $self->use('Bivio::Biz::Random')->hex_digits(8);
    my($ra) = $self->new_other('RealmAdmin');
    $req->with_realm(undef, sub {
	$ra->create_user($req->format_email($name), $name, $p, $name);
    });
    $ra->join_user('FREIKOMETER');
    return [$req->format_http('FREIKOMETER_UPLOAD'), $name, $p];
}

1;
