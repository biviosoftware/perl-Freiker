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

sub internal_upgrade_db_school_time_zone {
    my($self) = @_;
    my($map) = {
	edgemont070422305 => 'AMERICA_NEW_YORK',
	gladys207851304 => 'AMERICA_NEW_YORK',
	mount223052504 => 'AMERICA_NEW_YORK',
	crabapple300043760 => 'AMERICA_NEW_YORK',
	oxford386553000 => 'AMERICA_CHICAGO',
	mcfarland535589216 => 'AMERICA_CHICAGO',
	trek535941379 => 'AMERICA_CHICAGO',
	platteville538182139 => 'AMERICA_CHICAGO',
	seward554061331 => 'AMERICA_CHICAGO',
	beatrice683103904 => 'AMERICA_CHICAGO',
	martin787025415 => 'AMERICA_CHICAGO',
	bryker787031452 => 'AMERICA_CHICAGO',
	bikesportshop787071548 => 'AMERICA_CHICAGO',
	patsy78717 => 'AMERICA_CHICAGO',
	brentwood787572506 => 'AMERICA_CHICAGO',
	eldorado800274668 => 'AMERICA_DENVER',
	munroe802192730 => 'AMERICA_DENVER',
	william802383087 => 'AMERICA_DENVER',
	horizons803033732 => 'AMERICA_DENVER',
	crestview803040815 => 'AMERICA_DENVER',
	foothill803042145 => 'AMERICA_DENVER',
	casey803044130 => 'AMERICA_DENVER',
	creekside803055448 => 'AMERICA_DENVER',
	sanborn805011335 => 'AMERICA_DENVER',
	burlington805016330 => 'AMERICA_DENVER',
	eagle805037953 => 'AMERICA_DENVER',
	calhan808088619 => 'AMERICA_DENVER',
	matt891062510 => 'AMERICA_LOS_ANGELES',
	wendell891062832 => 'AMERICA_LOS_ANGELES',
	susan937283705 => 'AMERICA_LOS_ANGELES',
	egan940221210 => 'AMERICA_LOS_ANGELES',
	rita940221631 => 'AMERICA_LOS_ANGELES',
	almond940222312 => 'AMERICA_LOS_ANGELES',
	springer94040 => 'AMERICA_LOS_ANGELES',
	palo943011633 => 'AMERICA_LOS_ANGELES',
	lincoln950144054 => 'AMERICA_LOS_ANGELES',
	kennedy950144938 => 'AMERICA_LOS_ANGELES',
	gault950622525 => 'AMERICA_LOS_ANGELES',
	starlight950763160 => 'AMERICA_LOS_ANGELES',
	family974051602 => 'AMERICA_LOS_ANGELES',
	roosevelt974052997 => 'AMERICA_LOS_ANGELES',
	stratos981213309 => 'AMERICA_LOS_ANGELES',
	fatima981992624 => 'AMERICA_LOS_ANGELES',
	reeves985063299 => 'AMERICA_LOS_ANGELES',
	roosevelt985064359 => 'AMERICA_LOS_ANGELES',
	jamesn1m1j4 => 'AMERICA_TORONTO',
	stmaryn0b1s0 => 'AMERICA_TORONTO',
    };
    $self->model('RealmOwner')
	->do_iterate(
	    sub {
		my($it) = @_;
		return 1
		    if $it->is_default;
		my($rid, $name) = $it->get(qw(realm_id name));
		my($tz) = b_use('Type.TimeZone')
		    ->from_name($map->{$name} || 'AMERICA_DENVER');
		$tz->row_tag_replace(
		    $rid,
		    $tz,
		    $self->req,
		);
		my($count) = 0;
		$self->model('Ride')
		    ->do_iterate(
			sub {
			    my($it) = @_;
			    my($v) = $it->get_shallow_copy;
			    my($dt) = $tz->date_time_from_utc(
				$_DT->from_date_and_time(
				    $v->{ride_date},
				    $v->{ride_time},
				),
			    );
			    $it->unauth_create_or_update_keys({
				%$v,
				ride_date => b_use('Type.Date')->from_datetime($dt),
				ride_time => b_use('Type.Time')->from_datetime($dt),
			    });
			    $count++;
			    return 1;
			},
			'unauth_iterate_start',
			{club_id => $rid},
		    );
		b_info($name, ' ', $count);
		return 1;
	    },
	    'unauth_iterate_start',
	    {realm_type => [b_use('Auth.RealmType')->CLUB]},
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
