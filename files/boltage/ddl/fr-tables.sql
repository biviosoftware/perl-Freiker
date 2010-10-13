-- Copyright (c) 2005-2007 bivio Software, Inc.  All rights reserved.
-- $Id$
--
-- Data Definition Language for Freiker Models
--
-- * Tables are named after their models, but have underscores where
--   the case changes.  
-- * Make sure the type sizes match the Model field types--yes, this file 
--   should be generated from the Models...
-- * Don't put any constraints or indices here.  Put them in *-constraints.sql.
--   It makes it much easier to manage the constraints and indices this way.
--

CREATE TABLE freiker_code_t (
  freiker_code NUMERIC(9) NOT NULL,
  epc CHAR(24) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  CONSTRAINT freiker_code_t1 PRIMARY KEY(freiker_code)
)
/

CREATE TABLE freiker_info_t (
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  distance_kilometers NUMERIC(4,1),
  CONSTRAINT freiker_info_t1 PRIMARY KEY(user_id)
)
/

CREATE TABLE green_gear_t (
  green_gear_id NUMERIC(18) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  begin_date DATE NOT NULL,
  end_date DATE NOT NULL,
  must_be_registered NUMERIC(1) NOT NULL,
  must_be_unique NUMERIC(1) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT green_gear_t1 PRIMARY KEY(green_gear_id)
)
/

CREATE TABLE merchant_t (
  merchant_id NUMERIC(18) NOT NULL,
  CONSTRAINT merchant_t1 primary key(merchant_id)
)
/

CREATE TABLE prize_t (
  prize_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(4000) NOT NULL,
  detail_uri VARCHAR(255) NOT NULL,
  ride_count NUMERIC(9) NOT NULL,
  retail_price NUMERIC(9) NOT NULL,
  prize_status NUMERIC(2) NOT NULL,
  CONSTRAINT prize_t1 PRIMARY KEY(prize_id)
)
/

CREATE TABLE prize_coupon_t (
  coupon_code NUMERIC(9) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  prize_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  ride_count NUMERIC(9) NOT NULL,
  CONSTRAINT prize_coupon_t1 PRIMARY KEY(realm_id, coupon_code)
)
/

CREATE TABLE prize_receipt_t (
  coupon_code NUMERIC(9) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  receipt_code NUMERIC(9) NOT NULL,
  CONSTRAINT prize_receipt_t1 PRIMARY KEY(realm_id, coupon_code)
)
/

CREATE TABLE prize_ride_count_t (
  prize_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  ride_count NUMERIC(9) NOT NULL,
  CONSTRAINT prize_ride_count_t1 PRIMARY KEY(prize_id, realm_id)
)
/

CREATE TABLE ride_t (
  user_id NUMERIC(18) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  ride_date DATE NOT NULL,
  ride_time DATE NOT NULL,
  ride_upload_id NUMERIC(18),
  CONSTRAINT ride_t1 PRIMARY KEY(user_id, ride_date)
)
/

CREATE TABLE ride_upload_t (
  ride_upload_id NUMERIC(18) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  freikometer_user_id NUMERIC(18) NOT NULL,
  CONSTRAINT ride_upload_t1 PRIMARY KEY(ride_upload_id)
)
/

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
