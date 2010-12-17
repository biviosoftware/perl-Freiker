# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Freikometer;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_R) = b_use('IO.Ref');

sub USAGE {
    return <<'EOF';
usage: fr-freikometer [options] command [args..]
commands
  create name -- creates freikometer in realm
  create_zap name ethernet -- creates dero zap in realm
  do_all method args -- runs method with args on all fms
  do_command cmd ... -- runs cmd(s) on freikometer in shell
  download file ... -- downloads files to freikometer realm
  download_playlist -- downloads playlist for FM
  list_download -- lists the download folder
  list_upload -- lists the upload folder
  reboot -- reboots a freikometer
EOF
}

sub create {
    my($self, $name) = @_;
    my($req) = $self->initialize_fully;
    my($password) = _create($self, 'fm', $name, $name);
    return [
	$req->is_production ? 'https://fm.freikometer.net'
	    . $req->format_uri('BOT_FREIKOMETER_UPLOAD')
	    : $req->format_http('BOT_FREIKOMETER_UPLOAD'),
	$name,
	$password
    ];
}

sub create_zap {
    sub CREATE_ZAP {[[qw(name RealmName)], [qw(ethernet MACAddress)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->usage_error($bp->{ethernet}, ': ethernet already registered')
	if $self->model('RealmOwner')
        ->unauth_load({display_name => $bp->{ethernet}});
    return _create($self, 'dz', $bp->{name}, $bp->{ethernet});
}

sub do_all {
    my($self, $method_or_op, @args) = @_;
    return join(
	"\n",
	@{$self->model(
	    $self->req('auth_realm')->is_general ? 'AdmFreikometerList'
		: 'FreikometerList',
	)->map_iterate(sub {
            my($n) = shift->get('RealmOwner.name');
	    my($res) = $self->req->with_realm(
		$n,
		sub {
		    return ref($method_or_op) ? $method_or_op->(@args)
			: $self->$method_or_op(@args);
		},
	    );
	    return "$n:\n"
		. (ref($res) ? ${Bivio::IO::Ref->to_string($res)}
		       : defined($res) ? $res
		       : '')
		. "\n";
	})},
    );
}

sub do_command {
    my($self, @cmd) = shift->name_args(['Text'], \@_);
    return $self->download({
	filename => $_DT->local_now_as_file_name . '.sh',
	content => \(join("\n", @cmd, '')),
	content_type => 'text/plain',
    });
}

sub download {
    my($self, @file) = shift->name_args(['FileArg'], \@_);
    $self->usage_error(
	$self->req('auth_realm')->as_string,
	': -realm must be a freikometer',
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

sub download_playlist {
    my($self) = @_;
    my($req) = $self->req;
    return $self->download(
	$req->with_realm($req->get('auth_id'), sub {
	    return $req->with_user($req->get('auth_id'), sub {
                $self->model('RealmUser')->set_realm_for_freikometer;
		my($ring) = {@{
		    $req->with_user(undef, sub {
			return $self->model('ClubFreikerList')->map_iterate(
			    sub {
				my($it) = @_;
				return (
				    $it->get('RealmUser.user_id'),
				    $it->get('parent_display_name')
					? 'default' : 'unregistered',
				);
			    },
			);
		    })}};
		return +{
		    filename => 'playlist.pl',
		    content_type => 'text/plain',
		    content => $_R->to_string({@{
			$self->model('FreikerCodeList')->map_iterate(
			    sub {
				my($it) = @_;
				return (
				    $it->get('FreikerCode.epc'),
				    $ring->{$it->get('FreikerCode.user_id')},
				);
			    },
			),
		    }}),
		};
	    }),
	}),
    );
}

sub join_user_as_member {
    return shift->new_other('RealmAdmin')->join_user('MEMBER');
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

sub _create {
    my($self, $prefix, $name, $display_name) = @_;
    my($req) = $self->initialize_fully;
    $self->usage_error('name must begin with ${prefix}_')
	unless $name =~ /^${prefix}_\w+$/;
    $self->usage_error('you must set a club with -realm')
	unless $req->get_nested(qw(auth_realm type))->eq_club;
    my($p) = b_use('Bivio::Biz::Random')->hex_digits(8);
    my($ra) = $self->new_other('RealmAdmin');
    $req->with_realm(undef, sub {
        return $ra->create_user(
	    $req->format_email($name), $display_name, $p, $name);
    });
    $ra->join_user('FREIKOMETER');
    $req->set_realm($req->get('auth_user'));
    $self->new_other('RealmRole')->edit_categories('+feature_file');
    $self->new_other('RealmRole')->edit(qw(MEMBER -DATA_WRITE));
    $self->new_other('RealmRole')->do_super_users(
	sub {$self->join_user_as_member},
    );
    $self->model('Email')->load_for_auth_user->update({want_bulletin => 0});
    $self->model('RealmFile')->init_realm->map_invoke(
	create_folder => [
	    map([{path => $self->model($_)->FOLDER}],
		qw(FreikometerDownloadList FreikometerUploadList)),
	],
    );
    return $p;
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
