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
  do_all method args -- runs method with args on all fms
  do_command cmd ... -- runs cmd(s) on freikometer in shell
  download file ... -- downloads files to freikometer realm
  list_download -- lists the download folder
  list_upload -- lists the upload folder
  reboot -- reboots a freikometer
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

sub do_all {
    my($self, $method, @args) = shift->arg_list(\@_, [['Text']]);
    return join(
	"\n",
	@{$self->model('AdmFreikometerList')->map_iterate(sub {
            my($n) = shift->get('RealmOwner.name');
	    my($res) = $self->req->with_realm($n, sub {$self->$method(@args)});
	    return "$n:\n"
		. (ref($res) ? ${Bivio::IO::Ref->to_string($res)} : $res)
		. "\n";
	})},
    );
}

sub do_command {
    my($self, @cmd) = shift->arg_list(\@_, [['Text']]);
    return $self->download({
	filename => $_DT->local_now_as_file_name . '.sh',
	content => \(join("\n", @cmd, '')),
	content_type => 'text/plain',
    });
}

sub download {
    my($self, @file) = shift->arg_list(\@_, [['FileArg']]);
    $self->usage_error(
	$self->req('auth_realm'), ': -realm must be a freikometer',
    ) unless $self->req(qw(auth_realm type))->eq_user;
    return $self->req->with_user(
	$self->req('auth_user') || $self->req(qw(auth_realm owner)),
	sub {
	    map({
		my($f) = $_;
		$self->model('RealmFile')->create_or_update_with_content({
		    path => $_FP->join(
			$self->model('FreikometerDownloadList')->FOLDER,
			$f->{filename},
		    ),
		}, $f->{content})->get('path');
	    } @file);
	    return $self->list_download;
        },
    );
}

sub list_download {
    return _list('Download', @_);
}

sub list_upload {
    return _list('Upload', @_);
}

sub reboot {
    return shift->download({
	filename => '00-REBOOT',
	content => \('reboot'),
	content_type => 'text/plain',
    });
}

sub _list {
    my($which, $self) = @_;
    return join(
	"\n",
	@{$self->model("Freikometer${which}List")->map_iterate(sub {
            my($d, $p) = shift->get(qw(
	        RealmFile.modified_date_time
	        RealmFile.path
	    ));
	    return $_DT->to_local_string($d) . ' ' . ($p =~ m{([^/]+)$})[0];
	})},
    );
}

1;
