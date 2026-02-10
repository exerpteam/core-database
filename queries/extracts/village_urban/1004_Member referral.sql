-- The extract is extracted from Exerp on 2026-02-08
--  
 -- Parameters: from_date(LONG_DATE),to_date(LONG_DATE),scope(SCOPE)
 SELECT
     c.SHORTNAME                                                                                                                                                                            AS center,
     (CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
     END) AS PERSON_STATUS,
     p.center||'p'||p.id                                                                                                                                                                    AS Membership_ID,
     p.FULLNAME                                                                                                                                                                             AS MEMBER_NAME,

     CASE WHEN p.PERSONTYPE = 0 THEN 'PRIVATE' 
          WHEN p.PERSONTYPE = 1 THEN 'STUDENT' 
          WHEN p.PERSONTYPE = 2 THEN 'STAFF' 
          WHEN p.PERSONTYPE = 3 THEN 'FRIEND' 
          WHEN p.PERSONTYPE = 4 THEN 'CORPORATE' 
          WHEN p.PERSONTYPE = 5 THEN 'ONEMANCORPORATE' 
          WHEN p.PERSONTYPE = 6 THEN 'FAMILY' 
          WHEN p.PERSONTYPE = 7 THEN 'SENIOR' 
          WHEN p.PERSONTYPE = 8 THEN 'GUEST' 
          ELSE 'UNKNOWN' 
      END AS PERSONTYPE,

     pr.name                                                                                                                                                                                AS PERSON_SUBSCRIPTION ,
     TO_CHAR(longtodate(s.CREATION_TIME),'yyyy-MM-dd')                                                                                                                              AS Join_Date,
     TO_CHAR(s.START_DATE,'yyyy-MM-dd')                                                                                                                                                        START_DATE,
     c.SHORTNAME                                                                                                                                                                            AS center,
     a.NAME                                                                                                                                                                                 AS Region,
     pea_email.TXTVALUE                                                                                                                                                                     AS Member_email,
     pea_sms.TXTVALUE                                                                                                                                                                       AS Member_Mobile_Phone,
     c2.name                                                                                                                                                                                AS REFERRER_CLUB,
     (CASE referrer.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
     END) AS referrer_STATUS,
     
     referrer.center||'p'||referrer.id                                                                                                                                                      AS REFERRER_MEMBERSHIP_ID,
     referrer.FULLNAME                                                                                                                                                                      AS referrer_name,
    
     CASE WHEN referrer.PERSONTYPE = 0 THEN 'PRIVATE' 
          WHEN referrer.PERSONTYPE = 1 THEN 'STUDENT' 
          WHEN referrer.PERSONTYPE = 2 THEN 'STAFF' 
          WHEN referrer.PERSONTYPE = 3 THEN 'FRIEND' 
          WHEN referrer.PERSONTYPE = 4 THEN 'CORPORATE' 
          WHEN referrer.PERSONTYPE = 5 THEN 'ONEMANCORPORATE' 
          WHEN referrer.PERSONTYPE = 6 THEN 'FAMILY' 
          WHEN referrer.PERSONTYPE = 7 THEN 'SENIOR' 
          WHEN referrer.PERSONTYPE = 8 THEN 'GUEST' 
          ELSE 'UNKNOWN' 
      END AS referrer_PERSONTYPE,
     
     referrer.ADDRESS1                                                                                                                                                                      AS referrer_address,
     referrer.ZIPCODE                                                                                                                                                                       AS referrer_postcode,
     rp.NAME                                                                                                                                                                                AS referrer_membership,
     rpea_email.TXTVALUE                                                                                                                                                                    AS referrer_email,
     rpea_sms.TXTVALUE                                                                                                                                                                      AS referrer_MOBILE_phone
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
                 s2.END_DATE > longtodatetz(s.CREATION_TIME,'Europe/London') - interval '1 month'
                 OR s2.END_DATE IS NULL)
             AND s2.CREATION_TIME<s.CREATION_TIME
             AND s2.SUB_STATE !=8
             AND p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
             AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID )
