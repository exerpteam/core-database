SELECT 
  t1.MemberID,
  t1.Fullname,
  t1.GLOBALID,
  t1.Payment_Request_Count
FROM
(
SELECT
    p.CENTER||'p'||p.ID AS MemberID,
    p.FULLNAME,
    pr.GLOBALID,
    count(*) AS Payment_Request_Count,
    ar.center AS AR_CENTER,
    ar.id AS AR_ID,
    p.CENTER AS p_center,
    p.ID AS p_id
FROM
    PERSONS p 
JOIN  
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER 
    AND ar.CUSTOMERID = p.ID 
    AND ar.AR_TYPE = 4
JOIN
    SUBSCRIPTIONS s
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID
JOIN
    PRODUCTS pr
ON
    st.center = pr.center
    AND st.ID = pr.ID
JOIN
    CENTERS c
ON
    st.center = c.ID
JOIN
    PAYMENT_REQUESTS prq
ON
    prq.CENTER = ar.CENTER 
    AND prq.ID = ar.ID 
    AND prq.STATE < 5
    AND prq.REQUEST_TYPE = 1
WHERE
    st.ST_TYPE = 1 -- EFT
    AND c.COUNTRY = 'NO'  -- Norway
    AND p.STATUS = 1 -- Active
    AND pr.PTYPE = 10 -- Subscriptions
    AND s.STATE = 2 -- Active
    AND to_char(s.START_DATE,'YYYY-MM-DD') >= '2015-01-01'
    AND pr.GLOBALID in ('EFT_12_M','EFT_24_M','EFT_12_M_FITNESS_BATH','EFT_9_M','EFT_4_M_NEW','EFT_12M_SWIMMING','EFT_12_M_SWIMMING',
    'EFT_12_M_SWIMMING_2','EFT_12_M_REGIONAL','WEB_EFT_12_M_LOCAL','WEB_EFT_4_M','WEB_24_EFT_M','WEB_EFT_12_M','WEB_EFT_4_MONTHS')
GROUP BY p.center, p.id, p.FULLNAME, pr.GLOBALID, ar.center, ar.id
HAVING mod(count(*),12) = 0  
) t1
WHERE 
((GLOBALID IN ('EFT_24_M','WEB_24_EFT_M') AND payment_request_count >= 24)
OR 
(GLOBALID NOT IN ('EFT_24_M','WEB_24_EFT_M') AND payment_request_count >= 12))
AND NOT EXISTS 
(SELECT 1
 FROM
    AR_TRANS art
  WHERE
    art.CENTER = t1.AR_CENTER
    AND art.ID = t1.AR_ID
    AND art.REF_TYPE = 'INVOICE'
    AND art.AMOUNT = -99
    AND TRIM(art.TEXT) = 'Årlig administrasjonsavgift for medlemskap'
    AND longtodate(art.ENTRY_TIME) > add_months(sysdate,-12)
)
AND NOT EXISTS
(
SELECT 1
 FROM
     PRIVILEGE_CACHE pc
 JOIN
     PRIVILEGE_GRANTS pg
 ON 
     pg.id = pc.GRANT_ID
 JOIN 
     PRODUCT_PRIVILEGES pp
 ON
     pp.id = pc.PRIVILEGE_ID
 WHERE 
     person_center = t1.p_center 
     and person_id = t1.p_id
     and pg.GRANTER_SERVICE = 'CompanyAgreement'
     and (pc.VALID_TO is null  OR longtodate(pc.VALID_TO) > sysdate) 
     and pp.REF_GLOBALID = t1.GLOBALID
     and pg.SPONSORSHIP_NAME = 'FULL'
)