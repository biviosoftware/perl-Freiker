# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerSelectForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    my($fc) = $self->new_other('FreikerCode');
    return $self->internal_put_error(
	'FreikerCode.freiker_code' => 'NOT_FOUND',
    ) unless $fc->unauth_load(
	{freiker_code => $self->get('FreikerCode.freiker_code')});
    return {
	task_id => 'next',
	query => {
	    'ListQuery.parent_id' => $fc->get('user_id'),
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'FreikerCode.freiker_code',
	],
    });
}

1;
