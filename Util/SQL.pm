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
    my($self) = @_;
    my(@res) = shift->SUPER::initialize_db(@_);
    $self->new_other('SiteForum')->init;
    _freiker_distributor($self);
    return @res;
}

sub init_realm_role {
    my($self) = @_;
    my(@res) = shift->SUPER::init_realm_role(@_);
    $self->new_other('RealmRole')->copy_all(forum => 'merchant');
    return @res;
}

sub initialize_test_data {
    my($self) = @_;
    return $self->new_other('TestData')->initialize_db;
}    

sub internal_upgrade_db_freiker_info {
    my($self) = @_;
    $self->initialize_fully;
    $self->run(<<'EOF');
CREATE TABLE freiker_info_t (
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  distance_kilometers NUMERIC(4,1),
  CONSTRAINT freiker_info_t1 PRIMARY KEY(user_id)
)
/
CREATE INDEX freiker_info_t2 ON freiker_info_t (
  user_id
)
/
ALTER TABLE freiker_info_t
  ADD CONSTRAINT freiker_info_t3
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX freiker_info_t4 ON freiker_info_t (
  modified_date_time
)
/
CREATE INDEX freiker_info_t5 ON freiker_info_t (
  distance_kilometers
)
/
EOF
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

sub internal_upgrade_db_school_class {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE school_class_t (
  school_class_id NUMERIC(18) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  school_year_id NUMERIC(18) NOT NULL,
  school_grade NUMERIC(2) NOT NULL,
  CONSTRAINT school_class_t1 primary key(school_class_id)
)
/

CREATE TABLE school_year_t (
  school_year_id NUMERIC(18) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  start_date DATE NOT NULL,
  CONSTRAINT school_year_t1 primary key(school_year_id)
)
/
--
-- school_class_t
--
ALTER TABLE school_class_t
  ADD CONSTRAINT school_class_t2
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX school_class_t3 ON school_class_t (
  club_id
)
/
CREATE INDEX school_class_t4 ON school_class_t (
  school_grade
)
/

--
-- school_year_t
--
ALTER TABLE school_year_t
  ADD CONSTRAINT school_year_t2
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX school_year_t3 ON school_year_t (
  club_id
)
/
CREATE UNIQUE INDEX school_year_t4 ON school_year_t (
  club_id,
  start_date
)
/
CREATE SEQUENCE school_class_s
  MINVALUE 100024
  CACHE 1 INCREMENT BY 100000
/
CREATE SEQUENCE school_year_s
  MINVALUE 100029
  CACHE 1 INCREMENT BY 100000
/
EOF
    
    return;
}

sub internal_upgrade_db_ride_date_utc_delete {
    my($self) = @_;
    $self->model('RealmOwner')
	->do_iterate(
	    sub {
		my($ro) = @_;
		return 1
		    if $ro->is_default;
		my($rid, $name) = $ro->get(qw(realm_id name));
		my($tz) = b_use('Type.TimeZone')
		    ->row_tag_get($rid,, $self->req);
		my($deleted) = 0;
		my($total) = 0;
		$self->model('Ride')
		    ->do_iterate(
			sub {
			    my($it) = @_;
			    my($v) = $it->get_shallow_copy;
			    my($local) = $_DT->from_date_and_time(
				$v->{ride_date},
				$v->{ride_time},
			    );
			    my($utc) = $tz->date_time_to_utc($local);
			    $total++;
			    if ($_DT->is_equal($utc, $local)) {
				b_info($name, ': tz is UTC');
				return 0;
			    }
			    my($other) = $it->new;
			    return 1
				unless $other->unauth_load({
				    %$v,
				    ride_date => b_use('Type.Date')->from_datetime($utc),
				    ride_time => b_use('Type.Time')->from_datetime($utc),
				});
			    $other->unauth_delete;
			    $deleted++
				unless "@{[$_DT->get_parts($utc, 'minute', 'second')]}" eq '0 0';
			    return 1;
			},
			'unauth_iterate_start',
			{club_id => $rid},
		    );
		$total++;
		b_info($name, ' ', $deleted, ' ', $deleted/$total);
		die('too many deleted')
		    if $deleted/$total > 0.05;
		return 1;
	    },
	    'unauth_iterate_start',
	    'name asc',
	    {
		realm_type => [b_use('Auth.RealmType')->CLUB],
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
