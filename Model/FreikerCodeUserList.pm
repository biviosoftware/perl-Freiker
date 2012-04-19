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
    my($row) = $self->find_row_by('FreikerCode.user_id' => $user_id);
    return $_SA->new($row->get('freiker_codes'))
	if $row;
    return $_SA->new;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
	primary_key => ['FreikerCode.user_id'],
	auth_id => [{
	    name => 'FreikerCode.club_id',
	    in_select => 0,
	}],
	order_by => [qw(
	    FreikerCode.user_id
            FreikerCode.modified_date_time
	)],
	other => [
	    'FreikerCode.freiker_code',
	    {
		name => 'freiker_codes',
		type => 'StringArray',
		constraint => 'NOT_NULL',
	    },
	],
    });
}


sub internal_load_rows {
    my($self) = @_;
    my($prev);
    return [map(
	_unique($_, \$prev),
	@{shift->SUPER::internal_load_rows(@_)},
    )];
}

sub _unique {
    my($curr, $prev) = @_;
    if ($$prev
        && $$prev->{'FreikerCode.user_id'} eq $curr->{'FreikerCode.user_id'}
    ) {
	$$prev->{freiker_codes} = $$prev->{freiker_codes}
	    ->append($curr->{'FreikerCode.freiker_code'});
	return;
    }
    $curr->{freiker_codes} = $_SA->new($curr->{'FreikerCode.freiker_code'});
    return $$prev = $curr;
}

1;
