# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCode;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_EPC) = Bivio::Type->get_instance('EPC');
my($_BLOCK_SIZE) = 10000;
my($_R) = b_use('Biz.Random');
my($_EPC_PREFIX) = '465245494B455201';
my($_AR) = b_use('Auth.Role');

sub REALM_ID_FIELD {
    return 'club_id';
}

sub create_from_epc_and_code {
    my($self, $epc, $code) = @_;
    return $self->create({
	epc => $epc,
	freiker_code => $code,
	user_id => $self->new_other('User')->create_freiker($code),
    });
}

sub generate_for_block {
    my(undef, $block, $number, $generated) = @_;
    $generated ||= {};
    my($code);
    my($floor) = $block * $_BLOCK_SIZE;
    my($ceiling) = $floor + $_BLOCK_SIZE;
    if (defined($number)) {
	$code = $floor + $number;
	b_die('specified code already generated')
	    if $generated->{$code}++;
    } else {
	foreach my $try (1..10) {
	    my($d) = $_R->integer($ceiling, $floor);
	    next if $generated->{$d}++;
	    $code = $d;
	}
    }
    return {
	epc => sprintf("%s%08X", $_EPC_PREFIX, $code),
	print => $code,
    } if defined($code);
    b_die('could not generate code');
}

sub get_block_for_code {
    my(undef, $code) = @_;
    return int($code / $_BLOCK_SIZE);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'freiker_code_t',
	columns => {
	    freiker_code => ['FreikerCode', 'PRIMARY_KEY'],
	    epc => ['EPC', 'NOT_NULL'],
            user_id => ['User.user_id', 'NOT_NULL'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
        },
    });
}

sub reallocate_code {
    my($self, $dest_club_id) = @_;
    $self->new_other('RealmUser')->unauth_load_or_die({
	realm_id => $self->get('club_id'),
	user_id => $self->get('user_id'),
	role => $_AR->FREIKER,
    })->update({
	realm_id => $dest_club_id,
    });
    $self->update({
	club_id => $dest_club_id,
    });
    return;
}

sub unsafe_get_realm_ids {
    my($self, $freiker_code) = @_;
    return !$self->unauth_load({freiker_code => $freiker_code}) ? () : (
	$self->get(qw(user_id club_id)),
	$self->get_request->with_realm($self->get('user_id'), sub {
	    Bivio::Die->eval(sub {
	        $self->new_other('RealmUser')->get_any_online_admin;
	    });
	}),
    );
}

sub user_id_to_epc {
    # Must be in auth_realm of school
    my($self, $user_id) = @_;
    $self->throw_die(MODEL_NOT_FOUND => {entity => $user_id})
	unless $self->unsafe_load_first(
	    'modified_date_time desc', {user_id => $user_id});
    return $self->get('epc');
}

1;
