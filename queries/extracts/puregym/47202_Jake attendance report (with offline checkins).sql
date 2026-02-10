-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3862
 SELECT
     p.CURRENT_PERSON_CENTER                                                             AS remote_site_id
   , p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                          AS remote_user_id
   , TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'),'YYYY/MM/dd HH24:MI:SS') AS in_timestamp
   , ci.CHECKIN_CENTER                                                            AS location_site_id
   ,TRUNC(months_between(CURRENT_TIMESTAMP,p.BIRTHDATE) / 12)                                  AGE
   ,pc.sex
   ,CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END AS Person_Type
   ,pc.external_id
   ,first_value(prod.NAME) over (partition BY pc.CENTER,pc.ID ORDER BY s.CREATION_TIME DESC) subscription_name
 FROM
     CHECKINS ci
 JOIN
     PERSONS p
 ON
     p.CENTER = ci.PERSON_CENTER
     AND p.id = ci.PERSON_ID
 join PERSONS pc on
     pc.CENTER = p.CURRENT_PERSON_CENTER
     AND pc.id = p.CURRENT_PERSON_ID
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = pc.CENTER
     AND s.OWNER_ID = pc.ID
     AND s.STATE IN (2,4,8)
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 WHERE
     ci.CHECKIN_TIME >= $$FromDate$$
     AND ci.CHECKIN_TIME < ($$ToDate$$ + 24 * 3600 * 1000)
     AND ci.PERSON_CENTER IN ($$scope$$)
 UNION ALL
 SELECT
     p.CURRENT_PERSON_CENTER                                                             AS remote_site_id
   , p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                          AS remote_user_id
   , TO_CHAR(longtodateTZ(ou.TIMESTAMP, 'Europe/London'),'YYYY/MM/dd HH24:MI:SS') AS in_timestamp
   , ou.CENTER                                                            AS location_site_id
   ,TRUNC(months_between(CURRENT_TIMESTAMP,p.BIRTHDATE) / 12)                                  AGE
   ,pc.sex
   ,CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END AS Person_Type
   ,pc.external_id
   ,first_value(prod.NAME) over (partition BY pc.CENTER,pc.ID ORDER BY s.CREATION_TIME DESC) subscription_name
 FROM
     OFFLINE_USAGES ou
 JOIN
     PERSONS p
 ON
     p.CENTER = ou.PERSON_CENTER
     AND p.id = ou.PERSON_ID
 join PERSONS pc on
     pc.CENTER = p.CURRENT_PERSON_CENTER
     AND pc.id = p.CURRENT_PERSON_ID
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = pc.CENTER
     AND s.OWNER_ID = pc.ID
     AND s.STATE IN (2,4,8)
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 WHERE
     ou.TIMESTAMP >= $$FromDate$$
     AND ou.TIMESTAMP < ($$ToDate$$ + 24 * 3600 * 1000)
     AND ou.PERSON_CENTER IN ($$scope$$)
     AND ou.DEVICE_PART = 0
     AND NOT EXISTS
     (
        SELECT 1
     FROM
        CHECKINS c
     WHERE
        c.PERSON_CENTER = ou.PERSON_CENTER
        AND c.PERSON_ID = ou.PERSON_ID
        AND c.CHECKIN_TIME >= $$FromDate$$
        AND c.CHECKIN_TIME < ($$ToDate$$ + 24 * 3600 * 1000)
        --NOTE: if there is upto 1 minute difference between offline usage and checkin then don't count it
        AND ABS(c.CHECKIN_TIME - ou.timestamp) <=  60000
     )
