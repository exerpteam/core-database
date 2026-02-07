-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')      AS to_date,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') -183 AS monthago
        FROM
            centers c
        WHERE
            c.country = 'DK'
        AND c.id IN (:Scope)
    )
SELECT DISTINCT
    p.CENTER ||'p'|| p.id AS MEMBERID,
    p.external_id         AS ExternalID,
	p.BIRTHDATE			  AS birthdate,
    s.center              AS subscriptioncenter,
    s.id                  AS subscriptionid,
    s.subscription_price,
    pr.NAME      AS SUBSCRIPTION,
	pr.GLOBALID as GLOBALID,
    s.START_DATE AS STARTDATE,
    s.END_DATE   AS ENDDATE,
    t1.code
FROM
    PERSONS p
JOIN
    params
ON
    params.id = p.center
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
AND s.end_date IS NULL
--AND s.binding_end_date < params.to_date
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    subscriptiontypes st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND st.ID = s.SUBSCRIPTIONTYPE_ID
AND st.st_type = 1
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    p.center= ar.CUSTOMERCENTER
AND p.id=ar.CUSTOMERID
LEFT JOIN
    (
        SELECT
            pu.PERSON_CENTER,
            pu.PERSON_ID,
            cd.code,
            rank() over (partition by pu.PERSON_CENTER,
            pu.PERSON_ID order by pu.use_time) as rnk
        FROM
            PRIVILEGE_USAGES pu
        JOIN
            CAMPAIGN_CODES cd
        ON
            cd.ID = pu.CAMPAIGN_CODE_ID ) t1
ON
    t1.PERSON_CENTER = s.OWNER_CENTER
AND t1.PERSON_ID = s.OWNER_ID
and rnk = 1
WHERE
    s.state IN (2, 4, 8)
AND p.persontype = 0
AND p.center IN (:Scope)
--AND NOT EXISTS
--    (
--        SELECT
--            1
--        FROM
--            subscription_price sp
--        WHERE
--            s.center = sp.subscription_center
--        AND sp.subscription_id = s.id
--        AND sp.from_date > params.to_date )
