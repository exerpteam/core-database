-- The extract is extracted from Exerp on 2026-02-08
--  
select
t1."P NUMBER",
t1."SUBSCRIPTION",
t1."SOLD BY",
t1."EMAIL CHANNEL",
t1."SUBSCRIPTION SALE DATE",
t1."SUBSCRIPTION PRICE",
t1."ADD ON",
t1."PENDING INC AMOUNT",
t1."PENDING INC DATE"

from (

SELECT DISTINCT
    rank() over(partition by p.center ||'p'||p.ID ORDER BY sp.from_date ASC) as rnk,
    p.center ||'p'||p.ID  AS "P NUMBER",
    s.center ||'ss'||s.ID  AS "s NUMBER",
    prod.NAME             AS "SUBSCRIPTION",
    sales_person.FULLNAME AS "SOLD BY",
    CASE
        WHEN email.TXTVALUE IS NULL
        THEN 'FALSE'
        ELSE 'TRUE'
    END                                                         AS "EMAIL CHANNEL",
    TO_CHAR(longtodateC(s.CREATION_TIME,s.CENTER),'DD/MM/YYYY') AS "SUBSCRIPTION SALE DATE",
    (
        CASE
            WHEN st.ST_TYPE = 0
            THEN s.SUBSCRIPTION_PRICE
            WHEN (st.ST_TYPE = 1
                AND s.BINDING_END_DATE IS NOT NULL
                AND s.BINDING_END_DATE >= TRUNC(CURRENT_TIMESTAMP))
            THEN s.BINDING_PRICE
            ELSE s.SUBSCRIPTION_PRICE
        END) AS "SUBSCRIPTION PRICE",
    CASE
        WHEN addon_pr.center IS NOT NULL
        THEN 'True'
        ELSE 'False'
    END AS "ADD ON",
    sp.price     AS "PENDING INC AMOUNT",
    sp.from_date AS "PENDING INC DATE"
FROM
    PERSONS p
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
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND PROD.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.CENTER
AND ss.SUBSCRIPTION_ID = s.ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
AND emp.ID = ss.EMPLOYEE_ID
LEFT JOIN
    PERSONS sales_person
ON
    sales_person.CENTER = emp.PERSONCENTER
AND sales_person.ID = emp.PERSONID
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
AND email.PERSONID = p.ID
AND email.NAME = '_eClub_Email'
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    s.center = sa.subscription_center
AND s.id = sa.subscription_id
AND COALESCE(sa.end_date, CURRENT_TIMESTAMP) > CURRENT_TIMESTAMP -1
AND sa.cancelled = 0
LEFT JOIN
    MASTERPRODUCTREGISTER m
ON
    sa.ADDON_PRODUCT_ID=m.ID
LEFT JOIN
    PRODUCTS addon_pr
ON
    addon_pr.GLOBALID = m.GLOBALID
AND addon_pr.center = sa.CENTER_ID
AND COALESCE(sa.individual_price_per_unit, addon_pr.PRICE) > 0
LEFT JOIN
    subscription_price sp
ON
    sp.subscription_center = s.center
AND sp.subscription_id = s.id
and sp.cancelled != 'true'
AND sp.from_date > TO_DATE(getcentertime(s.center), 'YYYY-MM-DD')
WHERE
     s.STATE = 2  
   AND (P.CENTER,P.ID) IN (:members)
    )t1

Where
t1.rnk = 1 