# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::FreikerCode;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: bivio FreikerCode [options] command [args..]
commands
  import_csv -- imports rides
EOF
}

sub import_csv {
    my($self, $file) = @_;
    $self->model('FreikerCodeImportForm')->process({
	source => b_use('Type.FileField')->from_disk($file),
    });
    return;
}

1;
