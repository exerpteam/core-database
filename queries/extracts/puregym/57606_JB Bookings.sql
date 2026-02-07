SELECT 
           cen.NAME                                                                                                                    AS "Home club"
          ,bookingcen.name                                                                                                             AS "Booking center"
          ,person.center||'p'||person.id                                                                                               AS "PNumber"
          ,person.external_id                                                                                                          AS "External id"
          ,ag.name                                                                                                                     AS "Activity type"
          ,DECODE (USER_INTERFACE_TYPE, 0,'App', 1, 'Staff', 2,'Website' ,3,'KIOSK',  4,'SCRIPT',5,'API',6,'MOBILE API','UNKNOWN')     AS "Booking interface"
          ,TO_CHAR(longToDateTZ(bo.STARTTIME, 'Europe/London'),'YYYY-MM-DD HH24:MI')                                                   AS "Class start"
          ,TO_CHAR(longtodateTZ(par.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI')                                     AS "Booking date"
          ,TO_CHAR(longtodateTZ(par.CANCELATION_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI')                                  AS "Cancel date"
          ,an.name                                                                                                                     AS "activity"
          ,TRUNC(months_between(TRUNC(SYSDATE),person.BIRTHDATE) / 12)                                                                 AS "age"
          ,CASE
                WHEN prod.NAME is not null THEN  prod.NAME
                ELSE prodn.NAME
          END                                                                                                                          AS "SUB_COMMENT"
          ,DECODE(person.SEX,'M','Male','F','Female','Company')                                                                        AS "Gender"
          ,CASE
                WHEN ss.START_DATE is not Null THEN ss.START_DATE
                ELSE ssn.START_DATE
          END                                                                                                                          AS "LAST_SUB_START_DATE"
          ,(( TRUNC(SYSDATE - person.LAST_ACTIVE_START_DATE)) + 1)                                                                     AS "UNBROKEN_MEMBERSHIP_DAYS"
          ,par.CREATION_BY_CENTER || 'p' || par.CREATION_BY_ID                                                                         AS "Booking Created by ID"
          ,par.CANCELATION_BY_CENTER || 'p' || par.CANCELATION_BY_ID                                                                   AS "Booking Cancelled by ID"
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
    AND par.state = 'CANCELLED'
    AND bo.STARTTIME >= par.CANCELATION_TIME
    AND par.booking_center IN ($$scope$$)
    AND par.START_TIME >= ($$date_from$$)
    AND par.start_time <= ($$date_to$$)