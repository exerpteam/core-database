-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     p.CENTER                 Club
   , c.name                   club_name
   , s.center || 'ss' || s.id ssid
   ,s.END_DATE
   , prod.NAME AS SUBSCRIPTION
   , CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END as SUBSCRIPTION_STATE
   , CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END                                                                                     MemberStatus
   , p.CENTER || 'p' || p.ID                                                                                    MemberID
   , floor(months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE) / 12)                                                     CurrentAge
   , p.FIRSTNAME                                                                                                FirstName
   , p.LASTNAME                                                                                                 LastName
   , p.BIRTHDATE                                                                                                DOB
   , CASE st.ST_TYPE  WHEN 0 THEN  'FIXED_PERIOD'  WHEN 1 THEN  'RECURRING'  ELSE 'UNDEFINED' END                                         MembershipType
   , pg.NAME                                                                                                    MembershipCategory
   , s.BINDING_PRICE                                                                                            MemberPrice
   ,CASE WHEN cc.CENTER IS NOT NULL THEN 'YES' ELSE 'NO' END                                                                                         HasDebtCase
   ,CASE WHEN pm.CENTER IS NOT NULL THEN 'YES' ELSE 'NO' END                                                                                         HasOtherPayer
   , pm.CENTER || 'p' || pm.ID                                                                                  OtherPayerMemberId
   , CASE WHEN pm.center IS NOT NULL THEN pm.FIRSTNAME ELSE p.FIRSTNAME END                                                                   PayerFirstName
   , CASE WHEN pm.center IS NOT NULL THEN pm.LASTNAME ELSE p.LASTNAME END                                                                     PayerLastName
   , CASE WHEN pm.center IS NOT NULL THEN pm.ADDRESS1 ELSE p.ADDRESS1 END                                                                     PayerAddress1
   , CASE WHEN pm.center IS NOT NULL THEN pm.ADDRESS2 ELSE p.ADDRESS2 END                                                                     PayerAddress2
   , CASE WHEN pm.center IS NOT NULL THEN pm.ZIPCODE ELSE p.ZIPCODE END                                                                       PayerPostcode
   , CASE WHEN phoneSMS.TXTVALUE IS NOT NULL THEN phoneSMS.TXTVALUE ELSE phoneHome.TXTVALUE END                                               PayerContactTel
   , email.TXTVALUE                                               PayerEmail
   , c.PHONE_NUMBER                                                                                             ClubTelephone
   , CASE st.AGE_RESTRICTION_TYPE WHEN 1 THEN 'LESS THEN' WHEN 2 THEN 'MORE THEN' ELSE 'UNDEFINED' END || ' ' || st.AGE_RESTRICTION_VALUE AGE_RESTRICTION
   , TRUNC(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12) || ' years ' || TRUNC(mod(months_between (CURRENT_TIMESTAMP, p.BIRTHDATE),12)) || ' month ' || (CURRENT_DATE - add_months(p.BIRTHDATE, (months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12 ) * 12) + TRUNC(mod(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE),12)))::integer || ' days'
                                                                                                                           exact_current_age
   , ABS(to_date(TO_CHAR(CURRENT_DATE,'YYYY')::integer - st.AGE_RESTRICTION_VALUE || TO_CHAR(CURRENT_DATE,'mmDD'), 'YYYYmmDD') - p.BIRTHDATE) diff_in_days,
   sc.START_DATE changed_to_start_date,
   CASE  sc.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE null END as changed_to_state,
   prodC.NAME changed_to_name
 FROM
     SUBSCRIPTIONS s
 join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and prod.ID = s.SUBSCRIPTIONTYPE_ID
 left join SUBSCRIPTIONS sc on sc.CENTER = s.CHANGED_TO_CENTER and sc.ID = s.CHANGED_TO_ID
 left join PRODUCTS prodC on prodC.CENTER = sc.SUBSCRIPTIONTYPE_CENTER and prodC.ID = sc.SUBSCRIPTIONTYPE_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 LEFT JOIN
     RELATIVES rel
 ON
     rel.RELATIVECENTER = p.CENTER
     AND rel.RELATIVEID = p.ID
     AND rel.RTYPE IN (12)
     AND rel.STATUS = 1
 LEFT JOIN
     CASHCOLLECTIONCASES cc
 ON
     ((
             rel.RELATIVECENTER = cc.PERSONCENTER
             AND rel.RELATIVEID = cc.PERSONID)
         OR (
             cc.PERSONCENTER = p.CENTER
             AND cc.PERSONID = p.ID
             AND rel.RELATIVECENTER IS NULL))
     AND cc.CLOSED = 0
     AND cc.MISSINGPAYMENT = 1
 LEFT JOIN
     PERSONS pm
 ON
     pm.CENTER = rel.CENTER
     AND pm.ID = rel.ID
 LEFT JOIN
     PERSON_EXT_ATTRS phoneSMS
 ON
     ((
             phoneSMS.PERSONCENTER = rel.RELATIVECENTER
             AND phoneSMS.PERSONID = rel.RELATIVEID)
         OR (
             phoneSMS.PERSONCENTER = s.OWNER_CENTER
             AND phoneSMS.PERSONID = s.OWNER_ID
             AND rel.RELATIVECENTER IS NULL))
     AND phoneSMS.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS phoneHome
 ON
     ((
             phoneHome.PERSONCENTER = rel.RELATIVECENTER
             AND phoneHome.PERSONID = rel.RELATIVEID)
         OR (
             phoneHome.PERSONCENTER = s.OWNER_CENTER
             AND phoneHome.PERSONID = s.OWNER_ID
             AND rel.RELATIVECENTER IS NULL))
     AND phoneHome.NAME = '_eClub_PhoneHome'
     LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     ((
             email.PERSONCENTER = rel.RELATIVECENTER
             AND email.PERSONID = rel.RELATIVEID)
         OR (
             email.PERSONCENTER = s.OWNER_CENTER
             AND email.PERSONID = s.OWNER_ID
             AND rel.RELATIVECENTER IS NULL))
     AND email.NAME = '_eClub_Email'
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND st.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     centers c
 ON
     c.id = p.center
     AND c.COUNTRY = 'GB'
 WHERE
     st.AGE_RESTRICTION_TYPE = 1
     AND s.STATE IN (2,4,8)
 AND p.birthdate is not null
 AND extract(MONTH FROM TO_DATE($$Pick_Month$$,'YYYY-MM-DD')) = EXTRACT(MONTH FROM p.Birthdate)
 AND extract(YEAR FROM AGE(LAST_DAY(TO_DATE($$Pick_Month$$,'YYYY-MM-DD')),p.BIRTHDATE)) <= $$Maximum_Age$$ 
 AND C.ID NOT IN
 (400,
 401,
 403,
 406,
 407,
 411,
 419,
 434,
 435,
 436,
 440,
 441,
 442,
 443,
 450
 )
