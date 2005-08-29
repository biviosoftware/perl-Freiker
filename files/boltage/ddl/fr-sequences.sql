-- Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
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
CREATE sequence class_s
  MINVALUE 100021
  CACHE 1 INCREMENT BY 100000
/
CREATE sequence school_s
  MINVALUE 100022
  CACHE 1 INCREMENT BY 100000
/

