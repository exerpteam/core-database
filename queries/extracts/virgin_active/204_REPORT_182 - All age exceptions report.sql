-- The extract is extracted from Exerp on 2026-02-08
-- Finds any subscription in state ACTIVE, FROZEN, OR CREATED where the member are outside of the allowed age stan
 SELECT
     p.CENTER Club,
         c.name club_name,
         s.center || 'ss'  || s.id ssid,
     MEMBER_STATUS.TXTVALUE MemberStatus,
     p.CENTER || 'p' || p.ID MemberID,
     floor(months_between(TRUNC(current_timestamp),p.BIRTHDATE)/12) CurrentAge,
     p.FIRSTNAME FirstName,
     p.LASTNAME LastName,
     p.BIRTHDATE DOB,
     CASE st.ST_TYPE  WHEN 0 THEN  'FIXED_PERIOD'  WHEN 1 THEN  'RECURRING'  ELSE 'UNDEFINED' END MembershipType,
     pg.NAME MembershipCategory,
     s.BINDING_PRICE MemberPrice,
  s.END_DATE                   sub_stop_date,
     pm.CENTER || 'p' || pm.ID LinkedTo,
     pm.FIRSTNAME PrimaryFirstName,
     pm.LASTNAME PrimaryLastName,
     p.ADDRESS1 Address1,
     p.ADDRESS2 Address2,
     p.ZIPCODE Postcode,
     CASE WHEN phoneSMS.TXTVALUE IS NOT NULL THEN phoneSMS.TXTVALUE ELSE phoneHome.TXTVALUE END AS ContactTel,
     c.PHONE_NUMBER ClubTelephone,
     CASE st.AGE_RESTRICTION_TYPE WHEN 1 THEN 'LESS THEN' WHEN 2 THEN 'MORE THEN' ELSE 'UNDEFINED' END || ' ' || st.AGE_RESTRICTION_VALUE AGE_RESTRICTION,
     TRUNC(months_between(current_timestamp, p.BIRTHDATE)/12) || ' years ' || TRUNC(mod(months_between(current_timestamp, p.BIRTHDATE),12)) || ' month ' || (CURRENT_DATE - add_months(p.BIRTHDATE, (months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12 ) * 12) + TRUNC(mod(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE),12)))::integer || ' days' exact_current_age,
     ABS(to_date(TO_CHAR(current_timestamp,'YYYY')::integer-st.AGE_RESTRICTION_VALUE || TO_CHAR(current_timestamp,'mmDD'),'YYYYmmDD')- p.BIRTHDATE) diff_in_days
 FROM
     SUBSCRIPTIONS s
 LEFT JOIN PERSON_EXT_ATTRS MEMBER_STATUS
 ON
     MEMBER_STATUS.PERSONCENTER = s.OWNER_CENTER
     AND MEMBER_STATUS.PERSONID = s.OWNER_ID
     AND MEMBER_STATUS.NAME = 'MEMBER_STATUS'
 LEFT JOIN PERSON_EXT_ATTRS phoneSMS
 ON
     phoneSMS.PERSONCENTER = s.OWNER_CENTER
     AND phoneSMS.PERSONID = s.OWNER_ID
     AND phoneSMS.NAME = '_eClub_PhoneSMS'
 LEFT JOIN PERSON_EXT_ATTRS phoneHome
 ON
     phoneHome.PERSONCENTER = s.OWNER_CENTER
     AND phoneHome.PERSONID = s.OWNER_ID
     AND phoneHome.NAME = '_eClub_PhoneHome'
 JOIN SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND st.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN PRODUCTS prod
 ON
     prod.CENTER = st.CENTER
     AND prod.id = st.id
 JOIN PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 join centers c on c.id = p.center
 LEFT JOIN RELATIVES rel
 ON
     rel.CENTER = p.CENTER
     AND rel.ID = p.ID
     AND rel.RTYPE IN (4)
     AND rel.STATUS = 1
 LEFT JOIN PERSONS pm
 ON
     pm.CENTER = rel.RELATIVECENTER
     AND pm.ID = rel.RELATIVEID
 JOIN CENTERS c2
 ON
     c2.ID = p.center
 WHERE
     (
         (
             st.AGE_RESTRICTION_TYPE = 1
             AND floor(months_between(TRUNC(current_timestamp),p.BIRTHDATE)/12) < st.AGE_RESTRICTION_VALUE
         )
     )
     AND s.STATE IN (2,4,8)
     AND st.AGE_RESTRICTION_VALUE = $$restrictionAge$$
     AND floor(months_between(TRUNC(current_timestamp),p.BIRTHDATE)/12) < $$restrictionAge$$
     AND add_months(p.BIRTHDATE,12 * $$restrictionAge$$) BETWEEN :fromDate  AND :toDate +1
