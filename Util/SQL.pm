# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::SQL;
use strict;
use Bivio::Base 'ShellUtil';
use Bivio::Test::Language::HTTP;
use Freiker::Test;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_T);

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'fr']);
}

sub initialize_db {
    return shift->call_super_before(\@_, sub {
        my($self) = @_;
	$self->new_other('SiteForum')->init;
	_freiker_distributor($self);
        return;
    });
}

sub init_realm_role {
    return shift->call_super_before(\@_, sub {
        my($self) = @_;
	$self->new_other('RealmRole')->copy_all(forum => 'merchant');
        return;
    });
}

sub initialize_test_data {
    my($self) = @_;
    return $self->new_other('TestData')->initialize_db;
}    

sub internal_upgrade_db_freiker_info {
    my($self) = @_;
    $self->initialize_fully;
    $self->model('User')
	->do_iterate(
	    sub {
		my($it) = @_;
		my($v) = {realm_id => $it->get('user_id')};
		my($addr) = $it->new_other('Address');
		$addr->create($v)
		    unless $addr->unauth_load($v);
		return 1;
	    },
	    'unauth_iterate_start',
	    'user_id',
	);
    b_use('Biz.ListModel')->new_anonymous({
	primary_key => [
	    [qw(Address.realm_id RealmUser.user_id)],
	],
	other => [
	    [
		{
		    name => 'RealmUser.role',
		    in_select => 0,
		},
		[b_use('Auth.Role')->FREIKER],
	    ],
	    {
		name => 'RealmUser.realm_id',
		in_select => 0,
	    },
	    {
		name => 'Address.location',
		in_select => 0,
	    },
	],
	group_by => [
	    'Address.realm_id',
	    'Address.street2',
	],
    })->do_iterate(
	sub {
	    my($it) = @_;
	    my($fi) = $it->new_other('FreikerInfo');
	    my($uid) = $it->get('Address.realm_id');
	    return 1
		if $fi->unauth_load({user_id => $uid});
	    $fi->create({
		    user_id => $uid,
		    distance_kilometers => $it->get('Address.street2'),
		})
		->new_other('Address')
		->unauth_load_or_die({
		    realm_id => $uid,
		})
		->update({
		    street2 => undef,
		});
	    return 1;
	},
    );
    return;
}

sub _freiker_distributor {
    my($self) = @_;
    my($req) = $self->req;
    $req->with_realm(undef, sub {
	my($ral) = $self->model('RealmAdminList')->load_all
	    ->set_cursor_or_not_found(0);
	$req->with_user(
	    $ral->get('RealmUser.user_id'),
	    sub {
		$self->model('MerchantInfoForm', {
		    'RealmOwner.display_name' => 'Freiker, Inc.',
		    'Address.street1' => '2701 Iris Ave, Suite S',
		    'Address.city' => 'Boulder',
		    'Address.state' => 'CO',
		    'Address.zip' => '803042435',
		    'Website.url' => 'http://www.freiker.org',
		});
		$ral->do_rows(sub {
	            $self->model(RealmUserAddForm => {
			administrator => 1,
			'RealmUser.realm_id' => $self->req(qw(Model.Merchant merchant_id)),
			'User.user_id' => $ral->get('RealmUser.user_id'),
		    }),
	        });
		return;
	    },
	),
    });
    return;
}

1;
