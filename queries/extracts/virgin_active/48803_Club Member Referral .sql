-- The extract is extracted from Exerp on 2026-02-08
-- RG 24/12: Member referral report adapted for club use - Ref: #SR-232627
 -- Parameters: from_date(LONG_DATE),to_date(LONG_DATE),scope(SCOPE)
 SELECT
     --c.SHORTNAME                                                                                                                                                                            AS center,
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END        AS PERSON_STATUS ,
     p.center||'p'||p.id                                                                                                                                                                    AS Membership_ID,
     p.FULLNAME                                                                                                                                                                             AS MEMBER_NAME,
     --DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                               AS PERSONTYPE,
     pr.name                                                                                                                                                                                AS PERSON_SUBSCRIPTION ,
     TO_CHAR(longtodate(s.CREATION_TIME),'yyyy-MM-dd')                                                                                                                              AS Join_Date,
     --TO_CHAR(s.START_DATE,'yyyy-MM-dd')                                                                                                                                                     AS START_DATE,
     --TO_CHAR(s.binding_end_date,'yyyy-MM-dd')                                                                                                                                               AS BINDING_DATE,
     --TO_CHAR(s.end_date,'yyyy-MM-dd')                                                                                                                                                       AS STOP_DATE,
     --c.SHORTNAME                                                                                                                                                                            AS center,
     --a.NAME                                                                                                                                                                                 AS Region,
     --pea_email.TXTVALUE                                                                                                                                                                     AS Member_email,
     --pea_sms.TXTVALUE                                                                                                                                                                       AS Member_Mobile_Phone,
     c2.name                                                                                                                                                                                AS REFERRER_CLUB,
     CASE  referrer.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS referrer_STATUS ,
     referrer.center||'p'||referrer.id                                                                                                                                                      AS REFERRER_MEMBERSHIP_ID,
     referrer.FULLNAME                                                                                                                                                                      AS referrer_name,
     --DECODE ( referrer.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS referrer_PERSONTYPE,
     --referrer.EXTERNAL_ID                                                                                                                                                                   AS referrer_EXTERNAL_ID,
     --referrer.ADDRESS1                                                                                                                                                                      AS referrer_address,
     --referrer.ZIPCODE                                                                                                                                                                       AS referrer_postcode,
     rp.NAME                                                                                                                                                                                AS referrer_membership
     --rpea_email.TXTVALUE                                                                                                                                                                    AS referrer_email,
     --rpea_sms.TXTVALUE                                                                                                                                                                      AS referrer_MOBILE_phone,
     --TO_CHAR(longtodate(rs.CREATION_TIME),'yyyy-MM-dd')                                                                                                                             AS referrer_Join_Date,
     --TO_CHAR(rs.START_DATE,'yyyy-MM-dd')                                                                                                                                                    AS referrer_START_DATE,
     --TO_CHAR(rs.binding_end_date,'yyyy-MM-dd')                                                                                                                                              AS referrer_BINDING_DATE,
     --TO_CHAR(rs.end_date,'yyyy-MM-dd')                                                                                                                                                      AS referrer_STOP_DATE
 FROM
     PERSONS P
 JOIN
     SUBSCRIPTIONS S
 ON
     P.CENTER = S.OWNER_CENTER
     AND P.ID = S.OWNER_ID
     -- AND s.STATE IN (2,4,8)
 JOIN
     PRODUCTS pr
 ON
     pr.center = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
     AND pr.GLOBALID NOT IN( 'ANC_BY_DD',
                            'DUMMY_001')
 JOIN
     centers c
 ON
     p.center = c.id
 JOIN
     AREA_CENTERS ac
 ON
     ac.CENTER = c.ID
 JOIN
     AREAS a
 ON
     a.id = ac.AREA
     AND a.ROOT_AREA = 1
 LEFT JOIN
     PERSON_EXT_ATTRS pea_email
 ON
     pea_email.PERSONCENTER = p.center
     AND pea_email.PERSONID = p.id
     AND pea_email.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS pea_sms
 ON
     pea_sms.PERSONCENTER = p.center
     AND pea_sms.PERSONID = p.id
     AND pea_sms.NAME = '_eClub_PhoneSMS'
 JOIN
     relatives r2
 ON
     p.center = r2.center
     AND p.id = r2.id
     AND r2.rtype = 13
     AND r2.status = 1
 JOIN
     PERSONS oreferrer
 ON
     oreferrer.center = r2.RELATIVECENTER
     AND oreferrer.id =r2.RELATIVEID
 JOIN
     PERSONS referrer
 ON
     referrer.center = oreferrer.CURRENT_PERSON_CENTER
     AND referrer.id = oreferrer.CURRENT_PERSON_ID
 LEFT JOIN
     (
         SELECT
             rs.OWNER_CENTER,
             rs.OWNER_ID,
             MIN(rs.creation_time) AS creation_time
         FROM
             SUBSCRIPTIONS rs
         JOIN
             PRODUCTS rp
         ON
             rp.center = rs.SUBSCRIPTIONTYPE_CENTER
             AND rp.id = rs.SUBSCRIPTIONTYPE_ID
             AND rp.GLOBALID NOT IN( 'ANC_BY_DD',
                                    'DUMMY_001')
         WHERE
             rs.SUB_STATE != 8
             AND rs.STATE != 3
         GROUP BY
             rs.OWNER_CENTER,
             rs.OWNER_ID) ars
 ON
     ars.OWNER_CENTER = referrer.center
     AND ars.OWNER_ID = referrer.id
 LEFT JOIN
     SUBSCRIPTIONS rs
 ON
     rs.OWNER_CENTER = referrer.center
     AND rs.OWNER_ID = referrer.id
     AND rs.CREATION_TIME = ars.creation_time
 LEFT JOIN
     PRODUCTS rp
 ON
     rp.center = rs.SUBSCRIPTIONTYPE_CENTER
     AND rp.id = rs.SUBSCRIPTIONTYPE_ID
     AND rp.GLOBALID NOT IN( 'ANC_BY_DD',
                            'DUMMY_001')
 LEFT JOIN
     PERSON_EXT_ATTRS rpea_email
 ON
     rpea_email.PERSONCENTER = referrer.center
     AND rpea_email.PERSONID = referrer.id
     AND rpea_email.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS rpea_sms
 ON
     rpea_sms.PERSONCENTER = referrer.center
     AND rpea_sms.PERSONID = referrer.id
     AND rpea_sms.NAME = '_eClub_PhoneSMS'
 JOIN
     centers c_sub
 ON
     c_sub.id = s.center
 LEFT JOIN
     centers c2
 ON
     c2.id = referrer.center
 WHERE
     -- P.PERSONTYPE IN (4)
     --AND
     s.CREATION_TIME BETWEEN $$from_date$$ AND $$to_date$$
     AND s.center IN ($$scope$$)
     AND pr.PRIMARY_PRODUCT_GROUP_ID NOT IN(219,239,242,3207) --Mem Cat: Junior PAYP, Mem Cat: Junior DD, Mem Cat: Jnr PAYP, Mem Cat: Complimentary
     AND ( (
             rs.id IS NOT NULL
             AND rp.id IS NOT NULL)
         OR (
             rs.id IS NULL
             AND rp.id IS NULL) )
     AND s.SUB_STATE != 8
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             PERSONS p2
         JOIN
             SUBSCRIPTIONS s2
         ON
             s2.OWNER_CENTER = p2.center
             AND s2.OWNER_ID = p2.id
         WHERE
             (
                 s2.END_DATE > add_months(longtodatetz(s.CREATION_TIME,'Europe/London'),-1)
                 OR s2.END_DATE IS NULL)
             AND s2.CREATION_TIME<s.CREATION_TIME
             AND s2.SUB_STATE !=8
             AND p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
             AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID )
