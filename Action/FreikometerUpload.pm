# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FreikometerUpload;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_FP) = b_use('Type.FilePath');
my($_D) = b_use('Type.Date');
my($_RF) = b_use('Action.RealmFile');
my($_L) = b_use('IO.Log');
my($_M) = b_use('Biz.Model');
my($_CSV) = b_use('ShellUtil.CSV');

sub execute {
    my($proto, $req) = @_;
    return
	unless $req->is_http_method('put');
    $_M->new($req, 'RealmUser')->set_realm_for_freikometer;
    my($pi) = $_FP->get_clean_tail($req->get('path_info'));
    $_L->write_compressed(
	File::Spec->catfile(
	    $req->get('auth_user')->get('name'),
	    $_DT->local_now_as_file_name . '-' . $pi,
	),
	$req->get_content,
	$req,
    );
    $_M->new($req, 'RideImportForm')->process_content
        if $pi =~ /\.csv$/;
    $req->set_realm($req->get('auth_user'));
    $req->put(path_info => "/upload/@{[_ym()]}/$pi");
    $_RF->execute_put($req);
    $proto->reply_header_out(
	'X-FreikometerUpload', length(${$req->get_content}), $req);
    return;
}

sub execute_dero_zap {
    my($proto, $req) = @_;
    my($q) = Bivio::HTML->parse_www_form_urlencoded(${$req->get_content});
    my($realm) = _realm_name_from($q->{StationId});
    my($pi) = $_DT->local_now_as_file_name;
    $_L->write(
	File::Spec->catfile($realm, $pi . '.txt'),
	$req->get_content,
	$req,
    );
    return
        unless my $rowcount = $q->{bikeEventCount};
    my($rows) = [
        [qw(epc datetime)],
        map([$q->{"RfidNum$_"}, $q->{"BikeDateTime$_"}], 1..$rowcount),
    ];
    my($data) = b_use('IO.Ref')->to_string($rows);
    $_L->write(
	File::Spec->catfile($realm, $pi . '.csv'),
	$data,
	$req,
    );
    my($r) = b_use('Model.Ride')->new($req);
    my($m) = $r->new_other('RideImportForm');
    my($count) = 1;
    shift(@$rows);
    foreach my $item (@$rows) {
        $m->process_record({epc => $item->[0], datetime => $item->[1]},
                           $count++);
        return if $m->in_error;
    }
    $req->with_realm($realm, sub {
	$req->put(path_info => "/upload/$pi");
	$req->put(content => $data);
	$_RF->execute_put($req);
    });
    return;
}

sub reply_header_out {
    my(undef, $key, $value, $req) = @_;
    $req->get('r')->header_out($key, $value);
    return;
}

sub _realm_name_from {
    my($stationid) = @_;
#TODO: create Type.DeroZapStationId
    $stationid =~ s/://g;
    return 'dz_' . lc($stationid);
}

sub _ym {
    return join('', $_DT->get_parts($_DT->now, qw(year month)));
}

1;
