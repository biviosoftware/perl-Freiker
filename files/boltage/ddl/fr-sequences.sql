-- Copyright (c) 2005-2007 bivio Software, Inc.  All rights reserved.
-- $Id$
--
-- Sequences for bOP PetShop Models
--
--
-- * All sequences are unique for all sites.
--
-- * The five lower order digits are reserved for site and type.
-- * For now, we only have one site, so the lowest order digits are
--   reserved for type and the site is 0.
-- * CACHE 1 is required, because postgres keeps the cache on the
--   client side
--
----------------------------------------------------------------
--
-- Starting at 21.  1-20 is reserved for bOP common Models.
--
CREATE SEQUENCE prize_s
  MINVALUE 100021
  CACHE 1 INCREMENT BY 100000
/
CREATE SEQUENCE ride_upload_s
  MINVALUE 100022
  CACHE 1 INCREMENT BY 100000
/
CREATE SEQUENCE merchant_s
  MINVALUE 100023
  CACHE 1 INCREMENT BY 100000
/
CREATE SEQUENCE school_class_s
  MINVALUE 100024
  CACHE 1 INCREMENT BY 100000
/
CREATE SEQUENCE school_year_s
  MINVALUE 100029
  CACHE 1 INCREMENT BY 100000
/
CREATE SEQUENCE green_gear_s
  MINVALUE 100030
  CACHE 1 INCREMENT BY 100000
/
