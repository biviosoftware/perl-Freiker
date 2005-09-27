# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerLoginForm;
use strict;
$Freiker::Model::FreikerLoginForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::FreikerLoginForm::VERSION;

=head1 NAME

Freiker::Model::FreikerLoginForm - x

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::FreikerLoginForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Freiker::Model::FreikerLoginForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Freiker::Model::FreikerLoginForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

=cut

sub execute_ok {
    my($self) = @_;
    my($r) = $self->get('realm_owner');
    # no context is necessary to force workflow to info_task
    return $self->get_instance('UserLoginForm')
	->execute($self->get_request, {realm_owner => $r})
        || ($self->get_instance('FreikerInfoForm')->EMPTY_NAME
		eq $r->get('display_name')
	    || !$self->new_other('Class')
		->get_id_for_student($r->get('realm_id'))
	    ? 'info_task' : 0
	);
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
		[barcode => 'Barcode'],
		_map_ride_dates(
		    sub {
			my($d) = shift;
			[$d, 'Date', $d =~ /1/ ? 'NOT_NULL' : 'NONE']}),
	    ],
	    other => [
		[realm_owner => 'Bivio::Biz::Model::RealmOwner'],
	    ],
	    undef, 'NOT_NULL',
	)},
    });
}

=for html <a name="internal_post_execute"></a>

=head2 internal_post_execute()

=cut

sub internal_post_execute {
    shift->new_other('RideDateList')->load_page;
    return;
}

=for html <a name="validate"></a>

=head2 validate()

=cut

sub validate {
    my($self) = @_;
    return if $self->in_error;
    my($r) = $self->new_other('RealmOwner');
    return $self->internal_put_error(barcode => 'NOT_FOUND')
	unless $r->unauth_load({
	    name => $self->get('barcode'),
	    realm_type => Bivio::Auth::RealmType->USER,
	}) && $r->new_other('RealmUser')->unauth_load({
	    user_id => $r->get('realm_id'),
	    role => Bivio::Auth::Role->FREIKER,
	});
    my($i) = 3;
    my($j);
    _map_ride_dates(sub {$j++ if $self->unsafe_get(shift)});
    my($ok) = 0;
    $self->new_other('Ride')->do_iterate(
	sub {
	    my($d) = shift->get('ride_date');
	    $ok++
		if _map_ride_dates(
		    sub {($self->get(shift) || '') eq $d ? 1 : ()});
	    return --$i;
	},
	'ride_date desc',
	{user_id => $r->get('realm_id')},
    );
    # There may only be one or two rides.  There has to be at least one, or the
    # barcode wouldn't get into the system.
    if ($ok == $j && $ok == 3 - $i) {
	$self->internal_put_field(realm_owner => $r);
    }
    else {
	_map_ride_dates(
	    sub {$self->internal_put_error(shift, 'PASSWORD_MISMATCH')},
	);
    }
    return;
}

#=PRIVATE SUBROUTINES

# _map_ride_dates(code_ref op) : array
#
# Calls $op with ride_date1, ..., ride_date3 as first arg.
#
sub _map_ride_dates {
    my($op) = @_;
    return map($op->("ride_date$_"), 1..3);
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
