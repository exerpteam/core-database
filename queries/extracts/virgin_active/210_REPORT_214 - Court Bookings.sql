-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     book.NAME,
     par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID participant_pid,
     longToDateC(book.STARTTIME,book.center) STARTTIME,
     longToDateC(book.STOPTIME,book.center) STOPTIME,
     mpr.CACHED_PRODUCTNAME sub_name,
     pg.NAME primary_prod_group
 FROM
     ACTIVITY_GROUP ag
 JOIN ACTIVITY act
 ON
     act.ACTIVITY_GROUP_ID = ag.ID
 JOIN BOOKINGS book
 ON
     book.ACTIVITY = act.ID
 JOIN PARTICIPATIONS par
 ON
     par.BOOKING_CENTER = book.CENTER
     AND par.BOOKING_ID = book.ID
 LEFT JOIN PRIVILEGE_USAGES pu
 ON
     pu.TARGET_CENTER = par.CENTER
     AND pu.TARGET_ID = par.ID
     AND pu.TARGET_SERVICE = 'Participation'
 LEFT JOIN PRIVILEGE_GRANTS pgrant
 ON
     pgrant.ID = pu.GRANT_ID
     AND pgrant.GRANTER_SERVICE = 'GlobalSubscription'
 LEFT JOIN MASTERPRODUCTREGISTER mpr
 ON
     mpr.ID = pgrant.GRANTER_ID
 LEFT JOIN PRODUCT_GROUP pg
 ON
     pg.ID = mpr.PRIMARY_PRODUCT_GROUP_ID
 WHERE
     ag.NAME IN (
 'Adult Tennis Coaching Programme',
 'Adult groups',
 'Badminton',
 'Individual play',
 'Individual Play tennis',
 'Junior groups',
 'Outdoor tennis',
 'Pay and play',
 'Private lessons',
 'Racquets'
 )
         and par.start_time between $$fromTime$$ and $$toTime$$ * (1000*60*60*24)
     AND pu.ID IS NOT NULL
         and par.PARTICIPANT_CENTER in ($$scope$$)
     AND par.STATE = 'PARTICIPATION'
