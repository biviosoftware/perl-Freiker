# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
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
    $_M->new($req, 'RealmUser')
	->set_realm_for_zap(_zap_value('StationId', $_MA, $form, $req));
    _log('zap.txt', $req);
    _zap_rides(_zap_value('bikeEventCount', $_BEC, $form, $req), $form, $req);
    _realm_file(
	$_D->to_file_name($_D->local_today) . '-status.pl',
	$_R->to_string($form),
	$req,
    );
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
    return join('', $_D->get_parts($_D->local_today, qw(year month)));
}

sub _zap_die {
    my($entity, $msg, $form, $req) = @_;
    $req->throw_die(CORRUPT_FORM => {
	entity => $entity,
	message => $msg,
	form => $form,
    });
    # DOES NOT RETURN
}

sub _zap_rides {
    my($bec, $form, $req) = @_;
    return
	unless $bec > 0;
    my($rif) = $_M->new($req, 'RideImportForm');
    my($csv) = "EPC,DateTime\n";
    foreach my $i (0 .. $bec - 1) {
	my($bdt) = _zap_value("BikeDateTime$i", $_BDT, $form, $req);
	delete($form->{"bikedatetime$i"});
	my($rn) = _zap_value("RfidNum$i", $_EPC, $form, $req);
	delete($form->{"rfidnum$i"});
	$csv .= "$rn," . $_DT->to_file_name($bdt) . "\n";
    }
    $rif->process_content(\$csv);
    _realm_file(
	$_D->to_file_name($_D->local_today) . '.csv',
	\$csv,
	$req,
    );
    return;
}

sub _zap_value {
    my($key, $type, $form, $req) = @_;
    my($v, $err) = $type->from_literal($form->{lc($key)});
    _zap_die(
	$form->{lc($key)},
	"invalid $key: " . ($err || $_NULL)->get_name,
	$form,
	$req,
    ) unless defined($v);
    return $v;
}

1;
