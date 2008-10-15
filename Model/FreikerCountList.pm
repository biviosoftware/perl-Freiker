# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerCountList;
use strict;

NEED BOTH
select ride_date, name, count(*) from ride_t, realm_owner_t where ride_t.realm_id = realm_owner_t.realm_id and realm_owner_t.realm_type = 3 group by ride_date, name order by ride_date, name;


  select ride_date, name, count(*) from ride_t, realm_user_t, realm_owner_t where ride_t.realm_id = realm_user_t.user_id and realm_user_t.role = 5 and realm_owner_t.realm_type = 3 and realm_owner_t.realm_id = realm_user_t.realm_id group by ride_date, name order by ride_date, name;

# Count of freiker codes in use
select club_id, count(distinct freiker_code_t.freiker_code) from ride_t, freiker_code_t where freiker_code_t.freiker_code = ride_t.freiker_code group by club_id;
