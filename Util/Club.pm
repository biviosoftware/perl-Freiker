# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Club;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: fr-club [options] command [args..]
commands
  import_rides -- reads input for ride csv and imports into school
  import_codes -- reads input for freiker codes
EOF
}

sub import_codes {
    return _import(shift, 'FreikerCode');
}

sub import_rides {
    return _import(shift, 'Ride');
}

sub _import {
    my($self, $model) = @_;
    my($req) = $self->get_request;
    $self->usage_error('must be a club')
	unless $req->get_nested(qw(auth_realm type))->eq_club;
    return 'Imported '
	. Bivio::Biz::Model->new($req, $model)->import_csv($self->read_input)
	. " ${model}s\n";
}

1;
