-- Copyright (c) 2005-2007 bivio Software, Inc.  All rights reserved.
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
CREATE INDEX freiker_code_t4 ON freiker_code_t (
  user_id
)
/
ALTER TABLE freiker_code_t
  ADD CONSTRAINT freiker_code_t5
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE UNIQUE INDEX freiker_code_t6 ON freiker_code_t (
  epc
)
/
CREATE INDEX freiker_code_t7 ON freiker_code_t (
  modified_date_time
)
/

--
-- green_gear_t
--
CREATE INDEX green_gear_t2 ON green_gear_t (
  club_id
)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t3
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX green_gear_t4 ON green_gear_t (
  user_id
)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t5
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX green_gear_t6 ON green_gear_t (
  end_date
)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t7
  CHECK (must_be_registered BETWEEN 0 AND 1)
/
ALTER TABLE green_gear_t
  ADD CONSTRAINT green_gear_t8
  CHECK (must_be_unique BETWEEN 0 AND 1)
/
CREATE INDEX green_gear_t9 ON green_gear_t (
  creation_date_time
)
/

--
-- prize_t
--
ALTER TABLE prize_t
  ADD CONSTRAINT prize_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_t3 ON prize_t (
  realm_id
)
/
CREATE INDEX prize_t4 ON prize_t (
  modified_date_time
)
/
CREATE INDEX prize_t5 ON prize_t (
  name
)
/
CREATE INDEX prize_t6 ON prize_t (
  ride_count
)
/

--
-- prize_coupon_t
--
ALTER TABLE prize_coupon_t
  ADD CONSTRAINT prize_coupon_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_coupon_t3 ON prize_coupon_t (
  realm_id
)
/
ALTER TABLE prize_coupon_t
  ADD CONSTRAINT prize_coupon_t4
  FOREIGN KEY (prize_id)
  REFERENCES prize_t(prize_id)
/
CREATE INDEX prize_coupon_t5 ON prize_coupon_t (
  prize_id
)
/
ALTER TABLE prize_coupon_t
  ADD CONSTRAINT prize_coupon_t6
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX prize_coupon_t7 ON prize_coupon_t (
  user_id
)
/
CREATE INDEX prize_coupon_t8 ON prize_coupon_t (
  creation_date_time
)
/
CREATE INDEX prize_coupon_t9 ON prize_coupon_t (
  ride_count
)
/

--
-- price_ride_count_t
--
ALTER TABLE prize_ride_count_t
  ADD CONSTRAINT prize_ride_count_t2
  FOREIGN KEY (prize_id)
  REFERENCES prize_t(prize_id)
/
CREATE INDEX prize_ride_count_t3 ON prize_ride_count_t (
  prize_id
)
/
ALTER TABLE prize_ride_count_t
  ADD CONSTRAINT prize_ride_count_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_ride_count_t5 ON prize_ride_count_t (
  realm_id
)
/
CREATE INDEX prize_ride_count_t6 ON prize_ride_count_t (
  modified_date_time
)
/
CREATE INDEX prize_ride_count_t7 ON prize_ride_count_t (
  ride_count
)
/

--
-- prize_receipt_t
--
ALTER TABLE prize_receipt_t
  ADD CONSTRAINT prize_receipt_t2
  FOREIGN KEY (coupon_code, realm_id)
  REFERENCES prize_coupon_t(coupon_code, realm_id)
/
ALTER TABLE prize_receipt_t
  ADD CONSTRAINT prize_receipt_t3
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX prize_receipt_t4 ON prize_receipt_t (
  realm_id
)
/
ALTER TABLE prize_receipt_t
  ADD CONSTRAINT prize_receipt_t5
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX prize_receipt_t6 ON prize_receipt_t (
  user_id
)
/
CREATE INDEX prize_receipt_t7 ON prize_receipt_t (
  creation_date_time
)
/
CREATE UNIQUE INDEX prize_receipt_t8 ON prize_receipt_t (
  realm_id,
  receipt_code
)
/

--
-- ride_t
--
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX ride_t3 ON ride_t (
  user_id
)
/
CREATE INDEX ride_t4 ON ride_t (
  ride_date
)
/
ALTER TABLE ride_t
  ADD CONSTRAINT ride_t5
  FOREIGN KEY (ride_upload_id)
  REFERENCES ride_upload_t(ride_upload_id)
/
CREATE INDEX ride_t6 ON ride_t (
  ride_upload_id
)
/

--
-- ride_upload_t
--
ALTER TABLE ride_upload_t
  ADD CONSTRAINT ride_upload_t2
  FOREIGN KEY (club_id)
  REFERENCES club_t(club_id)
/
CREATE INDEX ride_upload_t3 ON ride_upload_t (
  club_id
)
/
ALTER TABLE ride_upload_t
  ADD CONSTRAINT ride_upload_t4
  FOREIGN KEY (freikometer_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX ride_upload_t5 ON ride_upload_t (
  freikometer_user_id
)
/
CREATE INDEX ride_upload_t4 ON ride_upload_t (
  creation_date_time
)
/
