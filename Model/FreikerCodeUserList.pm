# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCodeUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SA) = b_use('Type.StringArray');

sub LOAD_ALL_SIZE {
    return 10_000;
}

sub freiker_codes_for_user {
    my($self, $user_id) = @_;
    $self->load_all
	unless $self->is_loaded;
    return $_SA->new($self->find_row_by('FreikerCode.user_id' => $user_id)
	->get('freiker_codes'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => ['FreikerCode.user_id'],
	auth_id => [{
	    name => 'FreikerCode.club_id',
	    in_select => 0,
	}],
	order_by => [qw(
            FreikerCode.user_id
	)],
	other => [
	    {
		name => 'FreikerCode.freiker_code',
		in_select => 0,
	    },
	    {
		name => 'freiker_codes',
#BEBOP-7.80
#		type => 'StringArray',
		type => 'Text',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => q{group_concat(freiker_code) AS freiker_codes},
	    },
	],
	group_by => ['FreikerCode.user_id'],
    });
}
1;
