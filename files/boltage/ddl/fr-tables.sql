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

CREATE TABLE class_t (
  class_id NUMERIC(18) NOT NULL,
  school_id NUMERIC(18) NOT NULL,
  class_grade NUMERIC(2) NOT NULL,
  class_size NUMERIC(2) NOT NULL,
  school_year NUMERIC(4) NOT NULL,
  CONSTRAINT class_t1 PRIMARY KEY(class_id)
)
/

CREATE TABLE school_t (
  school_id NUMERIC(18) NOT NULL,
  website VARCHAR(255) NOT NULL,
  CONSTRAINT school_t1 PRIMARY KEY(school_id)
)
/

