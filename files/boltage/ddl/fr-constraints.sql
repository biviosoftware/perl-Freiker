-- Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
-- $Id$
--
-- Constraints & Indexes for Freiker Models
--
-- * This file is sorted alphabetically by table
-- * The only "NOT NULL" values are for things which are optional.
--   There should be very few optional things.  For example, there
--   is no such thing as an optional enum value.  0 should be used
--   for the UNKNOWN enum value.
-- * Booleans are: <name> NUMBER(1) CHECK (<name> BETWEEN 0 AND 1) NOT NULL,
-- * How to number all constraints sequentially:
--   perl -pi -e 's/(\w+_t)\d+/$1.++$n{$1}/e' bOP-constraints.sql
--   Make sure there is a table_tN ON each constraint--random N.
--
----------------------------------------------------------------

----------------------------------------------------------------
-- Non-PRIMARY KEY Constraints
----------------------------------------------------------------

--
-- club_aux_t
--
ALTER TABLE club_aux_t
  ADD CONSTRAINT club_aux_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE UNIQUE INDEX club_aux_t3 ON club_aux_t (
  website
)
/
CREATE INDEX club_aux_t4 ON club_aux_t (
  club_size
)
/

--
-- freiker_code_t
--
CREATE INDEX freiker_code_t2 ON freiker_code_t (
  club_id
)
/
ALTER TABLE freiker_code_t
  ADD CONSTRAINT freiker_code_t3
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/

--
-- ride
--
CREATE INDEX ride_t2 ON ride_t (
  freiker_code
)
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t3
  FOREIGN KEY (freiker_code)
  REFERENCES freiker_code_t(freiker_code)
/
CREATE INDEX ride_t4 ON ride_t (
  ride_date
)
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t5
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX ride_t6 ON ride_t (
  realm_id
)
/
CREATE INDEX ride_t7 ON ride_t (
  creation_date_time
)
/
