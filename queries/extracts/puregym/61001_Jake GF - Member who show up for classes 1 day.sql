-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     cen.NAME                                                                                                                            AS "Home club"
   , bookingcen.name                                                                                                                     AS "Booking center"
   , person.center||'p'||person.id                                                                                                       AS "PNumber"
   , person.fullname                                                                                                                     AS "Full Name"
   , person.external_id                                                                                                                  AS "External id"
   , ag.name                                                                                                                             AS "Activity type"
   , CASE  USER_INTERFACE_TYPE  WHEN 0 THEN 'App'  WHEN 1 THEN  'Staff'  WHEN 2 THEN 'Website'  WHEN 3 THEN 'KIOSK'   WHEN 4 THEN 'SCRIPT' WHEN 5 THEN 'API' WHEN 6 THEN 'MOBILE API' ELSE 'UNKNOWN' END             AS "Booking interface"
   , TO_CHAR(longToDateTZ(bo.STARTTIME, 'Europe/London'),'YYYY-MM-DD HH24:MI')                                                           AS "Class start"
   , TO_CHAR(longtodateTZ(par.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI')                                             AS "Booking date"
   , an.name                                                                                                                             AS "activity"
   , TRUNC(months_between(TRUNC(CURRENT_TIMESTAMP),person.BIRTHDATE) / 12)                                                                         AS "age"
   , CASE
                 WHEN prod.NAME is not null THEN  prod.NAME
                 ELSE prodn.NAME
     END                                                                                                                                 AS "SUB_COMMENT"
   , CASE person.SEX WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE 'Company' END                                                                                AS "Gender"
   , CASE
                 WHEN ss.START_DATE is not Null THEN ss.START_DATE
                 ELSE ssn.START_DATE
     END                                                                                                                                 AS "LAST_SUB_START_DATE"
 ,(( TRUNC(CURRENT_TIMESTAMP) - person.LAST_ACTIVE_START_DATE) + 1) UNBROKEN_MEMBERSHIP_DAYS
 , par.CREATION_BY_CENTER || 'p' || par.CREATION_BY_ID AS "Person Who Booked Class"
 FROM
     PERSONS person
 LEFT JOIN
         (SELECT max(ID) AS SubID,OWNER_CENTER,OWNER_ID,CENTER
         FROM SUBSCRIPTIONS
         WHERE STATE in (2,4,8)
         GROUP BY OWNER_CENTER,OWNER_ID,CENTER) s1
 ON
     s1.OWNER_CENTER = person.CENTER
     AND s1.OWNER_ID = person.ID
 LEFT JOIN
     SUBSCRIPTIONS ss
 ON
     s1.SubID = ss.ID
     AND s1.CENTER = ss.CENTER
     AND s1.OWNER_CENTER = ss.OWNER_CENTER
     AND s1.OWNER_ID = ss.OWNER_ID
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = ss.SUBSCRIPTIONTYPE_CENTER
     AND prod.id = ss.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
         (SELECT max(ID) AS SubID,OWNER_CENTER,OWNER_ID,CENTER
         FROM SUBSCRIPTIONS
         WHERE STATE not in (2,4,8)
         GROUP BY OWNER_CENTER,OWNER_ID,CENTER) s2
 ON
     s2.OWNER_CENTER = person.CENTER
     AND s2.OWNER_ID = person.ID
 LEFT JOIN
     SUBSCRIPTIONS ssn
 ON
     s2.SubID = ssn.ID
     AND s2.CENTER = ssn.CENTER
     AND s2.OWNER_CENTER = ssn.OWNER_CENTER
     AND s2.OWNER_ID = ssn.OWNER_ID
 LEFT JOIN
     PRODUCTS prodn
 ON
     prodn.CENTER = ssn.SUBSCRIPTIONTYPE_CENTER
     AND prodn.id = ssn.SUBSCRIPTIONTYPE_ID
 JOIN
     participations par
 ON
     person.center = par.participant_center
     AND person.id = par.participant_id
 JOIN
     privilege_usages pu
 ON
     par.center = pu.target_center
     AND par.id = pu.target_id
     AND PU.TARGET_SERVICE = 'Participation'
 JOIN
     bookings bo
 ON
     par.booking_center = bo.center
     AND par.booking_id = bo.id
 JOIN
     activity an
 ON
     bo.activity = an.id
 JOIN
     ACTIVITY_GROUP ag
 ON
     ag.ID = an.activity_group_id
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     mobile.PERSONCENTER = person.CENTER
     AND mobile.PERSONID = person.ID
     AND mobile.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS phonehome
 ON
     phonehome.PERSONCENTER = person.CENTER
     AND phonehome.PERSONID = person.ID
     AND phonehome.NAME = '_eClub_PhoneHome'
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = person.CENTER
     AND email.PERSONID = person.ID
     AND email.NAME = '_eClub_Email'
 JOIN
     CENTERS cen
 ON
     cen.ID = person.CENTER
 JOIN
     CENTERS bookingcen
 ON
     bookingcen.ID = bo.CENTER
 WHERE
     PU.privilege_type = 'BOOKING'
     AND par.state = 'PARTICIPATION'
     AND par.booking_center IN ($$scope$$)
  and par.start_time >= (TRUNC(CURRENT_TIMESTAMP-3)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000
     AND par.start_TIME < (TRUNC(CURRENT_TIMESTAMP-2)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000
     AND ag.id IN ($$activity_type$$)
 ORDER BY
     person.center
   , person.id
   , par.START_TIME
