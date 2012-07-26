# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ContactForm;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');
my($_ULF) = b_use('Model.UserLoginForm');

sub execute_empty {
    my($self) = @_;
    if (my $uid = $_ULF->unsafe_get_cookie_user_id($self->req)) {
	$self->new_other('RealmUser')->do_iterate(sub {
	    my($ru) = @_;
	    $self->internal_put_field(to =>
	        $self->new_other('SchoolContact')->unauth_load_or_die({
		    club_id => $ru->club_id_for_freiker($ru->get('user_id')),
		})->get('email'),
	    );
	    return 0;
	}, 'unauth_iterate_start', {
	    role => $_R->FREIKER,
	    realm_id => $uid,
	});
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'to',
		type => 'Email.email',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

1;
