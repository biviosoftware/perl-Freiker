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
-- class_t
--
ALTER TABLE class_t
  add constraint class_t2
  foreign key (school_id)
  references school_t(school_id)
/
CREATE INDEX class_t3 on class_t (
  school_id
)
/
CREATE INDEX class_t4 ON class_t (
  class_grade
)
/
CREATE INDEX class_t5 ON class_t (
  class_size
)
/
CREATE INDEX class_t6 ON class_t (
  school_year
)
/

--
-- school_t
--
CREATE UNIQUE INDEX school_t2 ON school_t (
  website
)
/
