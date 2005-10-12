# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::BarcodeUploadForm;
use strict;
$Freiker::Model::BarcodeUploadForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::BarcodeUploadForm::VERSION;

=head1 NAME

Freiker::Model::BarcodeUploadForm - barcodes

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::BarcodeUploadForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Freiker::Model::BarcodeUploadForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Freiker::Model::BarcodeUploadForm>

=cut

#=IMPORTS

#=VARIABLES
my($_D) = Bivio::Type->get_instance('Date');
my($_B) = Bivio::Type->get_instance('Barcode');
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Parses and inserts the rows.

=cut

sub execute_ok {
    my($self) = @_;
    $self->validate
	unless $self->[$_IDI];
    my($ok) = 0;
    foreach my $x (@{$self->[$_IDI]}) {
	my($c, $d) = @$x;
	$ok += _ride($self, {
	    user_id => _get_user($self, $c),
	    ride_date => $d,
	});
    }
#TODO: Consider a percentage, not just absolute
    $self->internal_put_error(barcode_file => 'EMPTY')
	unless $ok;
    $self->[$_IDI] = undef;
    Bivio::Biz::Action->get_instance('Acknowledgement')
        ->save_label('barcode_upload', $self->get_request)
	unless $self->in_error;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	@{$self->internal_initialize_local_fields(
	    visible => [
		[barcode_file => FileField => 'NOT_NULL'],
	    ],
	    other => [
		[file_errors => String => 'NONE'],
	    ],
	)},
    });
}

=for html <a name="validate"></a>

=head2 validate()

Checks codes and date.  Sets {rides} field.

=cut

sub validate {
    my($self) = @_;
    my($file) = $self->get('barcode_file');
    my($date) = $_D->from_literal($file->{filename} =~ m{(\d[-/\d\.]+\d)});
    my($n) = 1;
    my($errors) = [];
    my($rides) = [];
    foreach my $line (split(/[\r\n]+/, ${$file->{content}})) {
	next unless my($c, $d, $e) = _parse_line($self, $line, $date);
	push(@$errors, "line $n: $e")
	    if $e;
	last if !$d && $c;
	push(@$rides, [$c, $d])
	    unless $e;
    }
    continue {
	$n++;
	if (@$errors > 5) {
	    push(@$errors, 'too many errors');
	    last;
	}
    }
    if (@$errors) {
	$self->internal_put_error(barcode_file => 'NUMBER_RANGE');
	$self->internal_put_field(file_errors => join("\n", @$errors));
	return;
    }
    $self->[$_IDI] = $rides;
    return;
}

#=PRIVATE SUBROUTINES

# _get_user(self, string code) : string
#
# Returns user id for $code
#
sub _get_user {
    my($self, $code) = @_;
    my($ro) = $self->new_other('RealmOwner');
    unless ($ro->unauth_load({name => $code})) {
	my($en) = $self->get_instance('FreikerInfoForm')->EMPTY_NAME;
	$ro = ($self->new_other('User')->create_realm(
	    {last_name => $en},
	    {
#TODO: Implicit coupling; need to bind "name" to Type.Barcode
		name => $code,
		password => int(rand(100_000_000)),
		display_name => $en,
	    },
	))[1];
	$self->new_other('RealmUser')->create({
	    realm_id => $self->get_request->get('auth_id'),
	    user_id => $ro->get('realm_id'),
	    role => Bivio::Auth::Role->FREIKER,
	});
    }
    return $ro->get('realm_id');
}

# _parse_line(self, string line, string date) : array
#
# Returns ($code, $date, $error)
#
sub _parse_line {
    my($self, $line, $date) = @_;
    return if $line =~ /^\s+$/i;
    my($c, $d, $e);
    # Some scanners print Code128 on the line, which could be interpreted
    # as a barcode
    $line =~ s/\bCode128\b//i;
    unless ($c = ($_B->from_literal($line =~ $_B->REGEX))[0]) {
	$e = 'does not contain a barcode';
    }
    elsif (!($d = ($_D->from_literal($line =~ m{([-/\d]{8,})}))[0] || $date)) {
	$e = "File name must be a date or must be a date on every line";
    }
    elsif (!($d = ($_D->from_literal($line =~ m{([-/\d]{8,})}))[0] || $date)) {
	$e = "File name must be a date or must be a date on every line";
    }
    elsif ((my $sc = $_B->extract_school($c))
        ne (my $this = $self->get_request->get_nested(qw(auth_realm owner_name)))
    ) {
	$e = qq{barcode "$c" is not from this school "$this"};
    }
    return ($c, $d, $e);
}

# _ride(self, hash_ref values) : boolean
#
# Creates a ride entry
#
sub _ride {
    my($self, $values) = @_;
    my($r) = $self->new_other('Ride');
    return 0
	if $r->unsafe_load($values);
    $r->create($values);
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
