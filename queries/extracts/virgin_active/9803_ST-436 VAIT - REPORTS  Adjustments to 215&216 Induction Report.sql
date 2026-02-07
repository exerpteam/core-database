 select distinct * from
 (
 SELECT
     c.NAME                                   Club,
     to_char(longToDate(scl.ENTRY_START_TIME),'YYYY-MM-DD') MEMBER_CREATED,
     p.CENTER || 'p' || p.ID "Member ID",
     p.FULLNAME "Member Name",
     CASE WHEN par.CENTER IS NOT NULL THEN 1 ELSE 0 END "Induction Booked",
     longToDate(par.CREATION_TIME) "Date Booked",
     CASE
         WHEN par.STATE = 'PARTICIPATION'
         THEN 1
         ELSE 0
     END AS "Induction Attended",
     longToDate(par.SHOWUP_TIME) "Date Attended",
     ins.FULLNAME "Instructor",
     FIRST_VALUE(prod.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.CREATION_TIME asc) "subscription"
 FROM
     PERSONS p
 JOIN
     STATE_CHANGE_LOG scl
 ON
     scl.CENTER = p.CENTER
     AND scl.ID = p.ID
     AND scl.ENTRY_TYPE = 1
     AND scl.STATEID = 0
 left join SUBSCRIPTIONS s on s.OWNER_CENTER = p.CENTER and s.OWNER_ID = p.ID and s.STATE in (2,4,8)
 left join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and prod.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 LEFT JOIN
     PARTICIPATIONS par
 ON
     par.PARTICIPANT_CENTER = p.CENTER
     AND par.PARTICIPANT_ID = p.id
 LEFT JOIN
     BOOKINGS book
 ON
     book.CENTER = par.BOOKING_CENTER
     AND book.ID = par.BOOKING_ID
 LEFT JOIN
     ACTIVITY act
 ON
     act.ID = book.ACTIVITY
 LEFT JOIN
     ACTIVITY_GROUP actgr
 ON
     act.ACTIVITY_GROUP_ID = actgr.ID
 LEFT JOIN
     ACTIVITY_STAFF_CONFIGURATIONS staffconfig
 ON
     staffconfig.ACTIVITY_ID = act.ID
 LEFT JOIN
     STAFF_GROUPS stfg
 ON
     stfg.ID = staffconfig.STAFF_GROUP_ID
 LEFT JOIN
     STAFF_USAGE st
 ON
     book.center = st.BOOKING_CENTER
     AND book.id = st.BOOKING_ID
 LEFT JOIN
     PERSONS ins
 ON
     st.PERSON_CENTER = ins.CENTER
     AND st.PERSON_ID = ins.ID
 WHERE
 (
         act.ID IS NULL
         OR act.NAME = 'Check & Go' )
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             SUBSCRIPTIONS s2
         JOIN
             PRODUCTS prod2
         ON
             prod2.center = s2.SUBSCRIPTIONTYPE_CENTER
             AND prod2.ID = s2.SUBSCRIPTIONTYPE_ID
         JOIN
             PRODUCT_GROUP pg2
         ON
             pg2.ID = prod2.PRIMARY_PRODUCT_GROUP_ID
         WHERE
             s2.OWNER_CENTER = par.PARTICIPANT_CENTER
             AND s2.OWNER_ID = par.PARTICIPANT_ID
             AND s2.STATE IN (2,4)
                         and pg2.id in (219,239,242)
         )
     AND scl.ENTRY_START_TIME BETWEEN :createdFrom AND :createdTo + (1000*60*60*24)
     AND p.CENTER IN (:scope)
     and p.status in ($$person_status$$)
 ) t1
