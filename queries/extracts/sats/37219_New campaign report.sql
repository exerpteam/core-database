-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     cp.CENTER||'p'||cp.id memberid,
     cp.FULLNAME,
     c.SHORTNAME         center,
     pea_email.TXTVALUE  AS email,
     pea_mobile.TXTVALUE AS Mobile,
     pr.NAME             AS "Subscription Name",
     s.START_DATE,
     s.END_DATE
 FROM
     PERSONS cp
 JOIN
     PERSONS p
 ON
     p.CURRENT_PERSON_CENTER = cp.CENTER
     AND p.CURRENT_PERSON_ID = cp.id
 JOIN
     SUBSCRIPTIONS s
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = cp.CENTER
 JOIN
     PRODUCTS pr
 ON
     pr.center = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PERSON_EXT_ATTRS pea_email
 ON
     pea_email.PERSONCENTER = cp.center
     AND pea_email.PERSONID = cp.id
     AND pea_email.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS pea_mobile
 ON
     pea_mobile.PERSONCENTER = cp.center
     AND pea_mobile.PERSONID = cp.id
     AND pea_mobile.NAME = '_eClub_PhoneSMS'
 WHERE
 s.SUB_STATE != 8 and
     NOT EXISTS
     (
         SELECT
             *
         FROM
             PERSONS p2
         JOIN
             SUBSCRIPTIONS s2
         ON
             s2.OWNER_CENTER = p2.center
             AND s2.OWNER_ID = p2.id
             AND (
                 s2.SUB_STATE != 8)
         WHERE
             p2.CURRENT_PERSON_CENTER = cp.center
             AND p2.CURRENT_PERSON_ID = cp.id
             AND (
                 s2.END_DATE BETWEEN add_months(s.START_DATE,-1) AND s.START_DATE-1
                 OR s2.START_DATE <= s.START_DATE-1) )
     AND s.START_DATE = TRUNC(current_timestamp - 1)
     AND p.CURRENT_PERSON_CENTER IN ($$scope$$)
     AND ((
             p.CURRENT_PERSON_CENTER::VARCHAR NOT IN ($$centers_list$$)
             AND $$action$$='Exclude')
         OR (
             p.CURRENT_PERSON_CENTER::VARCHAR IN ($$centers_list$$)
             AND $$action$$='Include_only')
         OR (
             $$action$$='Include_all'))
