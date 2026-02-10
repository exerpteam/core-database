-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.name                                                                                                                                                                          AS "Club name",
    CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS Person_STATUS,
    CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END                                                                                          AS Subscription_STATE,
    CASE ST_TYPE  WHEN 0 THEN  'Cash'  WHEN 1 THEN  'EFT'  WHEN 3 THEN  'Prospect' END                                                                                                                             AS Subscription_TYPE,
    s.OWNER_CENTER||'p'||s.OWNER_ID                                                                                                                                                 AS MemberID,
    s.center||'ss'||s.id "eClub subscription ID",
    pr.name AS subscription,
    s.START_DATE,
    s.END_DATE,
    s.SUBSCRIPTION_PRICE,
    pr.PRICE AS Product_Price
FROM
    SUBSCRIPTIONS s
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr
ON
    pr.center = st.center
    AND pr.id = st.id
JOIN
    CENTERS c
ON
    c.id = s.center
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            SUBSCRIPTION_PRICE sp
        WHERE
            sp.SUBSCRIPTION_CENTER = s.CENTER
            AND sp.SUBSCRIPTION_ID = s.id
            AND sp.FROM_DATE >=CURRENT_TIMESTAMP
            AND sp.PRICE != 0)
    AND s.STATE IN ($$state$$)
    AND st.ST_TYPE IN ($$type$$)
    AND s.center IN ($$scope$$)
    AND s.SUBSCRIPTION_PRICE = 0
    AND pr.name NOT IN('Ancillary by DD base subscription',
                       'Academy Level One 1 Month',
                       'Academy Level Four 1 Month',
                       'Deployment PT',
                       'Junior Complimentary')
	AND pr.name NOT like '%Junior%'
    AND pr.name NOT like '%Funded%'
   AND NOT (pr.name = 'Multiclub Racquets Joint Flexi' and s.center = 419)
    