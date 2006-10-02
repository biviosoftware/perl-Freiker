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

CREATE TABLE ride_t (
  freiker_code NUMERIC(9) NOT NULL,
  ride_date DATE NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT ride_t1 PRIMARY KEY(freiker_code, ride_date)
)
/
