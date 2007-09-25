# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Freikometer;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: fr-freikometer [options] command [args..]
commands
  create name -- creates freikometer in realm
  download file ... - downloads files to freikometer realm
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
    $req->set_realm($req->get('auth_user'));
    $self->model('RealmFile')->init_realm->map_invoke(
	create_folder => [
	    map([{path => $self->model($_)->FOLDER}],
		qw(FreikometerDownloadList FreikometerUploadList)),
	],
    );
    return [$req->format_http('BOT_FREIKOMETER_UPLOAD'), $name, $p];
}

sub download {
    my($self, @files) = shift->arg_list(\@_, ['FileArg']);
    $self->usage_error(
	$self->req('auth_realm'), ': -realm must be a freikometer',
    ) unless $self->req(qw(auth_realm type))->eq_user;
    my($suffix) = qr{^(?:rpm|pl|sh|tgz)$};
    return [map({
	my($f) = $_;
	$self->usage_error($f->{filename}, ": suffix must match $suffix")
	    unless $_FP->get_suffix($f->{filename}) =~ $suffix;
	$self->model('RealmFile')->create_with_content({
	    path => $_FP->join(
		$self->model('FreikometerDownloadList')->FOLDER,
		$_DT->local_now_as_file_name. '-' . $f->{filename},
	    ),
	}, $f->{content})->get('path');
    } @files)];
}

1;
