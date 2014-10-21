# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Facade;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_F) = b_use('UI.Facade');
my($_IOF) = b_use('IO.File');

sub USAGE {
    return <<'EOF';
usage: fr-facade [options] command [args...]
commands:
    text_table_csv file_name -- export Facade Text table as csv to file_name
EOF
}
sub text_table_csv {
    my($self, $file_name) = @_;
    my($req) = $self->initialize_fully;
    my($all) = $_F->get_value('Text', $req)->internal_get_all;
    my($rows) = [['Element', 'Label']];
    my($count) = 0;
    foreach my $f (@$all) {
	foreach my $n (@{$f->{names}}) {
	    unless ($n =~ /task_menu\.title\.sort_/) {
		push(@$rows, [$n, $f->{value}]);
		$count++;
	    }
	}
    }
    my($csv) = $self->new_other('CSV')->sort_csv(
	$self->new_other('CSV')->to_csv_text($rows));
    $_IOF->write($file_name, $csv);
    $self->print("$count rows written to $file_name\n");
    return;
}

1;
