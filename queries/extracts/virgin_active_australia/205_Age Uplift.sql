-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     p.CENTER                 AS Club,
     c.name                   AS club_name,
     s.center || 'ss' || s.id AS ssid,
     s.END_DATE,
     prod.NAME                AS SUBSCRIPTION,
     CASE  
         WHEN s.STATE = 2 THEN 'ACTIVE'  
         WHEN s.STATE = 3 THEN 'ENDED'  
         WHEN s.STATE = 4 THEN 'FROZEN'  
         WHEN s.STATE = 7 THEN 'WINDOW'  
         WHEN s.STATE = 8 THEN 'CREATED'  
         ELSE 'UNKNOWN'  
     END AS SUBSCRIPTION_STATE,
     CASE  
         WHEN p.STATUS = 0 THEN 'LEAD'  
         WHEN p.STATUS = 1 THEN 'ACTIVE'  
         WHEN p.STATUS = 2 THEN 'INACTIVE'  
         WHEN p.STATUS = 3 THEN 'TEMPORARYINACTIVE'  
         WHEN p.STATUS = 4 THEN 'TRANSFERRED'  
         WHEN p.STATUS = 5 THEN 'DUPLICATE'  
         WHEN p.STATUS = 6 THEN 'PROSPECT'  
         WHEN p.STATUS = 7 THEN 'DELETED'  
         WHEN p.STATUS = 8 THEN 'ANONYMIZED'  
         WHEN p.STATUS = 9 THEN 'CONTACT'  
         ELSE 'UNKNOWN'  
     END AS MemberStatus,
     p.CENTER || 'p' || p.ID AS MemberID,
     EXTRACT(YEAR FROM AGE(DATE_TRUNC('day', CURRENT_TIMESTAMP), p.BIRTHDATE)) AS CurrentAge,
     p.FIRSTNAME AS FirstName,
     p.LASTNAME AS LastName,
     p.BIRTHDATE AS DOB,
     CASE  
         WHEN st.ST_TYPE = 0 THEN 'FIXED_PERIOD'  
         WHEN st.ST_TYPE = 1 THEN 'RECURRING'  
         ELSE 'UNDEFINED'  
     END AS MembershipType,
     pg.NAME AS MembershipCategory,
     s.BINDING_PRICE AS MemberPrice,
     CASE  
         WHEN cc.CENTER IS NOT NULL THEN 'YES'  
         ELSE 'NO'  
     END AS HasDebtCase,
     CASE  
         WHEN pm.CENTER IS NOT NULL THEN 'YES'  
         ELSE 'NO'  
     END AS HasOtherPayer,
     pm.CENTER || 'p' || pm.ID AS OtherPayerMemberId,
     COALESCE(pm.FIRSTNAME, p.FIRSTNAME) AS PayerFirstName,
     COALESCE(pm.LASTNAME, p.LASTNAME) AS PayerLastName,
     COALESCE(pm.ADDRESS1, p.ADDRESS1) AS PayerAddress1,
     COALESCE(pm.ADDRESS2, p.ADDRESS2) AS PayerAddress2,
     COALESCE(pm.ZIPCODE, p.ZIPCODE) AS PayerPostcode,
     COALESCE(phoneSMS.TXTVALUE, phoneHome.TXTVALUE) AS PayerContactTel,
     email.TXTVALUE AS PayerEmail,
     c.PHONE_NUMBER AS ClubTelephone,
     CASE  
         WHEN st.AGE_RESTRICTION_TYPE = 1 THEN 'LESS THAN'  
         WHEN st.AGE_RESTRICTION_TYPE = 2 THEN 'MORE THAN'  
         ELSE 'UNDEFINED'  
     END || ' ' || st.AGE_RESTRICTION_VALUE AS AGE_RESTRICTION,
     EXTRACT(YEAR FROM AGE(DATE_TRUNC('day', CURRENT_TIMESTAMP), p.BIRTHDATE)) || ' years ' ||
     EXTRACT(MONTH FROM AGE(DATE_TRUNC('day', CURRENT_TIMESTAMP), p.BIRTHDATE)) || ' months ' ||
     EXTRACT(DAY FROM AGE(DATE_TRUNC('day', CURRENT_TIMESTAMP), p.BIRTHDATE)) || ' days' AS exact_current_age,
     ABS(
         (TO_DATE(
             TO_CHAR(EXTRACT(YEAR FROM DATE_TRUNC('day', CURRENT_TIMESTAMP))::INTEGER - st.AGE_RESTRICTION_VALUE, '9999') ||
             TO_CHAR(DATE_TRUNC('day', CURRENT_TIMESTAMP), 'MMDD'), 'YYYYMMDD'
         ) - p.BIRTHDATE)
     ) AS diff_in_days,
     sc.START_DATE AS changed_to_start_date,
     CASE  
         WHEN sc.STATE = 2 THEN 'ACTIVE'  
         WHEN sc.STATE = 3 THEN 'ENDED'  
         WHEN sc.STATE = 4 THEN 'FROZEN'  
         WHEN sc.STATE = 7 THEN 'WINDOW'  
         WHEN sc.STATE = 8 THEN 'CREATED'  
         ELSE NULL  
     END AS changed_to_state,
     prodC.NAME AS changed_to_name
FROM SUBSCRIPTIONS s
JOIN PRODUCTS prod 
    ON prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER 
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN SUBSCRIPTIONS sc 
    ON sc.CENTER = s.CHANGED_TO_CENTER 
    AND sc.ID = s.CHANGED_TO_ID
LEFT JOIN PRODUCTS prodC 
    ON prodC.CENTER = sc.SUBSCRIPTIONTYPE_CENTER 
    AND prodC.ID = sc.SUBSCRIPTIONTYPE_ID
JOIN PERSONS p 
    ON p.CENTER = s.OWNER_CENTER 
    AND p.ID = s.OWNER_ID
LEFT JOIN RELATIVES rel 
    ON rel.RELATIVECENTER = p.CENTER 
    AND rel.RELATIVEID = p.ID 
    AND rel.RTYPE IN (12) 
    AND rel.STATUS = 1
LEFT JOIN CASHCOLLECTIONCASES cc 
    ON (
        (rel.RELATIVECENTER = cc.PERSONCENTER AND rel.RELATIVEID = cc.PERSONID) 
        OR (cc.PERSONCENTER = p.CENTER AND cc.PERSONID = p.ID AND rel.RELATIVECENTER IS NULL)
    )
    AND cc.CLOSED = 0 
    AND cc.MISSINGPAYMENT = 1
LEFT JOIN PERSONS pm 
    ON pm.CENTER = rel.CENTER 
    AND pm.ID = rel.ID
LEFT JOIN PERSON_EXT_ATTRS phoneSMS 
    ON (
        (phoneSMS.PERSONCENTER = rel.RELATIVECENTER AND phoneSMS.PERSONID = rel.RELATIVEID) 
        OR (phoneSMS.PERSONCENTER = s.OWNER_CENTER AND phoneSMS.PERSONID = s.OWNER_ID AND rel.RELATIVECENTER IS NULL)
    )
    AND phoneSMS.NAME = '_eClub_PhoneSMS'
LEFT JOIN PERSON_EXT_ATTRS phoneHome 
    ON (
        (phoneHome.PERSONCENTER = rel.RELATIVECENTER AND phoneHome.PERSONID = rel.RELATIVEID) 
        OR (phoneHome.PERSONCENTER = s.OWNER_CENTER AND phoneHome.PERSONID = s.OWNER_ID AND rel.RELATIVECENTER IS NULL)
    )
    AND phoneHome.NAME = '_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS email 
    ON (
        (email.PERSONCENTER = rel.RELATIVECENTER AND email.PERSONID = rel.RELATIVEID) 
        OR (email.PERSONCENTER = s.OWNER_CENTER AND email.PERSONID = s.OWNER_ID AND rel.RELATIVECENTER IS NULL)
    )
    AND email.NAME = '_eClub_Email'
JOIN SUBSCRIPTIONTYPES st 
    ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER 
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN PRODUCT_GROUP pg 
    ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN centers c 
    ON c.id = p.center 
WHERE st.AGE_RESTRICTION_TYPE = 1
    AND s.STATE IN (2,4,8)
    AND p.birthdate IS NOT NULL
    AND EXTRACT(MONTH FROM TO_DATE($$Pick_Month$$, 'YYYY-MM-DD')) = EXTRACT(MONTH FROM p.BIRTHDATE)
    AND EXTRACT(YEAR FROM AGE(
        (DATE_TRUNC('month', TO_DATE($$Pick_Month$$, 'YYYY-MM-DD')) + INTERVAL '1 month' - INTERVAL '1 day'), 
        p.BIRTHDATE
    )) <= $$Maximum_Age$$

