# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerUpload;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_FP) = b_use('Type.FilePath');
my($_D) = b_use('Type.Date');
my($_L) = b_use('IO.Log');
my($_M) = b_use('Biz.Model');
my($_MA) = b_use('Type.MACAddress');
my($_BEC) = b_use('Type.BikeEventCount');
my($_EPC) = b_use('Type.EPC');
my($_R) = b_use('IO.Ref');
my($_BDT) = b_use('Type.BikeDateTime');
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_DIE) = b_use('Bivio.Die');
my($_V) = b_use('UI.View');
my($_A) = b_use('IO.Alert');

sub execute {
    my($proto, $req) = @_;
    return
	unless $req->is_http_method('put');
    $_M->new($req, 'RealmUser')->set_realm_for_freikometer;
    my($pi) = $_FP->get_clean_tail($req->get('path_info'));
    _log($pi, $req);
    $_M->new($req, 'RideImportForm')->process_content
        if $pi =~ /\.csv$/;
    _realm_file($pi, $req->get_content, $req);
    $proto->reply_header_out(
	'X-FreikometerUpload', length(${$req->get_content}), $req);
    return;
}

sub execute_zap {
    my($proto, $req) = @_;
    return
	unless $req->is_http_method('post');
    my($form) = $req->get_form;
    $form = {map((lc($_) => $form->{$_}), keys(%$form))};
    my($err) = [];
    my($die) = $_DIE->catch_quietly(sub {
	$_M->new($req, 'RealmUser')
	    ->set_realm_for_zap(
		_zap_value('StationId', $_MA, $form, $req, $err) || return,
	);
	_log('zap.txt', $req);
	_zap_rides(
	    _zap_value('bikeEventCount', $_BEC, $form, $req, $err),
	    $form,
	    $req,
	    $err,
	);
	_realm_file(
	    $_D->to_file_name($_D->local_today) . '-status.pl',
	    $_R->to_string($form),
	    $req,
	);
    });
    unshift(@$err, $die->as_string)
	if $die;
    return
	unless @$err;
    $proto->new({
	station_id => $form->{stationid} || '',
	form => ${$_R->to_string($form)},
	errors => join("\n", @$err),
    })->put_on_request($req);
    $_V->execute('General->zap_error_mail', $req);
    return;
}

sub reply_header_out {
    my(undef, $key, $value, $req) = @_;
    $req->get('r')->header_out($key, $value);
    return;
}

sub _log {
    my($path_info, $req) = @_;
    $_L->write_compressed(
	File::Spec->catfile(
	    $req->get('auth_user')->get('name'),
	    $_DT->local_now_as_file_name . '-' . $path_info,
	),
	$req->get_content,
	$req,
    );
    return;
}

sub _realm_file {
    my($path_info, $content, $req) = @_;
    $req->set_realm($req->get('auth_user'));
    my($rf) = $_M->new($req, 'RealmFile');
    $rf->create_or_update_with_content(
	{path => $rf->parse_path("/Upload/@{[_ym()]}/$path_info")},
	$content,
    );
    return;
}

sub _ym {
    return sprintf(
	'%04d%02d',
	$_D->get_parts($_D->local_today, qw(year month)),
    );
}

sub _zap_warn {
    my($entity, $msg, $form, $req, $err) = @_;
    push(@$err, $_A->format_args($entity, ': ', $msg, ' ', $form));
    return;
}

sub _zap_rides {
    my($bec, $form, $req, $err) = @_;
    return
	unless $bec > 0;
    my($rif) = $_M->new($req, 'RideImportForm');
    my($csv) = "EPC,DateTime\n";
    foreach my $i (0 .. $bec - 1) {
	my($bdt) = _zap_value("BikeDateTime$i", $_BDT, $form, $req, $err);
	delete($form->{"bikedatetime$i"});
	my($rn) = _zap_value("RfidNum$i", $_EPC, $form, $req, $err);
	delete($form->{"rfidnum$i"});
	next
	    unless $rn && $bdt;
	$csv .= "$rn," . $_DT->to_file_name($bdt) . "\n";
    }
    return
	unless $csv =~ /\n.*\n/s;
    $rif->process_content(\$csv);
    _realm_file(
	$_D->to_file_name($_D->local_today) . '.csv',
	\$csv,
	$req,
    );
    return;
}

sub _zap_value {
    my($key, $type, $form, $req, $err) = @_;
    my($v, $e) = $type->from_literal($form->{lc($key)});
    return _zap_warn(
	$form->{lc($key)},
	"invalid $key: " . ($e || $_NULL)->get_name,
	$form,
	$req,
	$err,
    ) unless defined($v);
    return $v;
}

1;
