# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Action::FamilyPrizePickup;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RU) = __PACKAGE__->use('Model.RealmUser');
my($_C) = __PACKAGE__->use('FacadeComponent.Constant');

sub execute {
    my($proto, $req) = @_;
    return {
	realm => $_C->get_value(site_realm_name => $req),
	query => undef,
	task_id => 'FORUM_WIKI_VIEW',
        path_info => $_RU->new_other('RealmOwner')->unauth_load_or_die({
	    realm_id => $_RU->new($req)->club_id_for_freiker(
	        $req->get_nested(qw(Model.FreikerList RealmUser.user_id))),
	})->get('name')
	. '_party',
    };
}

1;

