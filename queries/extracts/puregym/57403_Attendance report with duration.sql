-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8104
 SELECT
     p.CURRENT_PERSON_CENTER                                                             AS "Member home centre"
   , p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                                 AS "Member id"
   , TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'),'YYYY/MM/dd HH24:MI')        AS "Date & time in"
   , TO_CHAR(longtodateTZ(ci.CHECKOUT_TIME, 'Europe/London'),'YYYY/MM/dd HH24:MI')       AS "Date & time out"
   , round((ci.CHECKOUT_TIME - ci.CHECKIN_TIME)/60000,2)                                 AS "VISIT_DURATION (minutes)"
   , CASE ci.IDENTITY_METHOD  WHEN 1 THEN  'BARCODE'  WHEN 2 THEN  'MAGNETIC_CARD'  WHEN 3 THEN  'SSN'
          WHEN 4 THEN  'RFID_CARD'  WHEN 5 THEN  'PIN'  WHEN 6 THEN  'ANTI DROWN'  WHEN 7 THEN  'QRCODE'  ELSE 'UNKNOWN' END              AS "Access method"
   , ei.IDENTITY                                                                         AS "Member card number"
   , ci.CHECKIN_CENTER                                                                   AS "Visited club"
   , 'On-line'                                                                           AS "Access mode"
   ,TRUNC(months_between(CURRENT_TIMESTAMP,p.BIRTHDATE) / 12)                                      AS "AGE"
   ,pc.sex                                                                               AS "Sex"
   ,CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 
         'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END  AS "Person_Type"
   ,pc.external_id                                                                       AS "EXTERNAL_ID"
   ,first_value(prod.NAME) over (partition BY pc.CENTER,pc.ID ORDER BY s.CREATION_TIME DESC) AS "Subscription_name"
 FROM
     CHECKINS ci
 JOIN
     PERSONS p
 ON
     p.CENTER = ci.PERSON_CENTER
     AND p.id = ci.PERSON_ID
 JOIN
     PERSONS pc
 ON
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
 LEFT JOIN
     ENTITYIDENTIFIERS ei
 ON
     ei.REF_TYPE = 1
     AND ei.IDMETHOD = 4
     AND ei.REF_CENTER = pc.CENTER
     AND ei.REF_ID = pc.ID
     AND ci.CHECKIN_TIME >= ei.START_TIME
     AND ((ci.CHECKIN_TIME < ei.STOP_TIME) or ei.STOP_TIME is null)
 WHERE
     ci.CHECKIN_TIME >= $$FromDate$$
     AND ci.CHECKIN_TIME < ($$ToDate$$ + 24 * 3600 * 1000)
     AND ci.CHECKIN_CENTER IN ($$scope$$)
 UNION ALL
 SELECT
     p.CURRENT_PERSON_CENTER                                                             AS "Member home centre"
   , p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                                 AS "Member id"
   , TO_CHAR(longtodateTZ(ou.TIMESTAMP, 'Europe/London'),'YYYY/MM/dd HH24:MI')        AS "Date & time in"
   , null                                                                                AS "Date & time out"
   , null                                                                                AS "VISIT_DURATION (minutes)"
   , CASE ou.CARD_IDENTITY_METHOD  WHEN 1 THEN  'BARCODE'  WHEN 2 THEN  'MAGNETIC_CARD'  WHEN 3 THEN  'SSN'
          WHEN 4 THEN  'RFID_CARD'  WHEN 5 THEN  'PIN'  WHEN 6 THEN  'ANTI DROWN'  WHEN 7 THEN  'QRCODE'  ELSE 'UNKNOWN' END              AS "Access method"
   , ou.CARD_IDENTITY                                                                    AS "Member card number"
   , ou.CENTER                                                                           AS "Visited club"
   , 'Off-line'                                                                          AS "Access mode"
   ,TRUNC(months_between(CURRENT_TIMESTAMP,p.BIRTHDATE) / 12)                                      AS "AGE"
   ,pc.sex                                                                               AS "Sex"
   ,CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 
         'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END  AS "Person_Type"
   ,pc.external_id                                                                       AS "EXTERNAL_ID"
   ,first_value(prod.NAME) over (partition BY pc.CENTER,pc.ID ORDER BY s.CREATION_TIME DESC) AS "Subscription_name"
 FROM
     OFFLINE_USAGES ou
 JOIN
     PERSONS p
 ON
     p.CENTER = ou.PERSON_CENTER
     AND p.id = ou.PERSON_ID
 JOIN
     PERSONS pc
 ON
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
     AND ou.CENTER IN ($$scope$$)
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
