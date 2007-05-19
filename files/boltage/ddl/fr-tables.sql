-- Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
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

CREATE TABLE club_aux_t (
  realm_id NUMERIC(18) NOT NULL,
  website VARCHAR(255) NOT NULL,
  club_size NUMERIC(9) NOT NULL,
  CONSTRAINT club_aux_t1 PRIMARY KEY(realm_id)
)
/

CREATE TABLE freiker_code_t (
  freiker_code NUMERIC(9) NOT NULL,
  club_id NUMERIC(18) NOT NULL,
  CONSTRAINT freiker_code_t1 PRIMARY KEY(freiker_code)
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
  freiker_code NUMERIC(9) NOT NULL,
  ride_date DATE NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  ride_time DATE NOT NULL,
  is_manual_entry NUMERIC(1) NOT NULL,
  CONSTRAINT ride_t1 PRIMARY KEY(freiker_code, ride_date)
)
/
