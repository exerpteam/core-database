-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS 
    (
        SELECT
            datetolongC(TO_CHAR(CURRENT_DATE-5, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS FROMDATE,
            datetolongC(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS TODATE
    )
    ,
    V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER AS center,
            ppgl.PRODUCT_ID     AS id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
SELECT DISTINCT
    np.EXTERNAL_ID                                                 AS "EXTERNALID",
    su.center||'ss'||su.id                                         AS "SUBSCRIPTIONID",
    su.START_DATE                                                  AS "STARTDATE",
    su.END_DATE                                                    AS "ENDDATE",
    su.SUBSCRIPTIONTYPE_CENTER || 'prod' || su.SUBSCRIPTIONTYPE_ID                   AS "PRODUCTID",
 COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE))::VARCHAR AS  "CURRENTPRICE",
    ROUND(COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)::NUMERIC, 2) AS "NORMALPRICE",
    TO_CHAR(longtodate(su.CREATION_TIME) , 'YYYY-MM-DD')         AS "MEMBERSIGNUPDATE",
    ROUND(il.TOTAL_AMOUNT::NUMERIC, 2)                           AS "PRICEJFEE",
    CASE
        WHEN il.TOTAL_AMOUNT < il.PRODUCT_NORMAL_PRICE
        THEN 1
        ELSE 0
    END AS "DISCOUNTEDJFEE",
    CASE COALESCE(ss.PRICE_ADMIN_FEE,0)
        WHEN 0
        THEN 0
        ELSE 1
    END AS "PAIDCHARITYDONATION",
    CASE su.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS "STATE",
    CASE su.SUB_STATE
        WHEN 1
        THEN 'NONE'
        WHEN 2
        THEN 'AWAITING_ACTIVATION'
        WHEN 3
        THEN 'UPGRADED'
        WHEN 4
        THEN 'DOWNGRADED'
        WHEN 5
        THEN 'EXTENDED'
        WHEN 6
        THEN 'TRANSFERRED'
        WHEN 7
        THEN 'REGRETTED'
        WHEN 8
        THEN 'CANCELLED'
        WHEN 9
        THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END AS "SUBSTATE",
    CASE sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID
        WHEN 'ss'
        THEN NULL
        ELSE sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID
    END                                                                      AS "NEWSUBSCRIPTIONID",
    TO_CHAR(longtodateC(su.LAST_MODIFIED,100),'YYYY-MM-DD HH24:MI:SS') AS
    "LASTMODIFIEDDATE"
FROM
    PERSONS p
CROSS JOIN
    PARAMS
JOIN
    PERSONS np
ON
    np.CENTER = p.CURRENT_PERSON_CENTER
AND np.id = p.CURRENT_PERSON_ID
JOIN
    SUBSCRIPTIONS su
ON
    su.OWNER_CENTER = p.CENTER
AND su.OWNER_ID = p.ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = su.SUBSCRIPTIONTYPE_CENTER
AND st.id = su.SUBSCRIPTIONTYPE_ID
AND (
        ST.CENTER, ST.ID) NOT IN
    (
        SELECT
            center,
            id
        FROM
            V_EXCLUDED_SUBSCRIPTIONS)

LEFT JOIN
    SUBSCRIPTION_PRICE SP
ON
    (
        SP.SUBSCRIPTION_CENTER = SU.CENTER
    AND SP.SUBSCRIPTION_ID = SU.ID
    AND sp.CANCELLED = 0
    AND SP.FROM_DATE <= greatest(CURRENT_DATE, su.start_date)
    AND (
            SP.TO_DATE IS NULL
        OR  SP.TO_DATE >= greatest(CURRENT_DATE, su.start_date) ) )


LEFT JOIN
     SUBSCRIPTIONPERIODPARTS SPP
 ON
     (
         SPP.CENTER = SU.CENTER
         AND SPP.ID = SU.ID
         AND SPP.FROM_DATE <= greatest(CURRENT_DATE, su.start_date)
         AND ( SPP.TO_DATE >= greatest(CURRENT_DATE, su.start_date) )
         AND SPP.SPP_STATE = 1
         AND SPP.ENTRY_TIME < datetolong(to_char(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI')) )
LEFT JOIN
    SUBSCRIPTION_CHANGE sc
ON
    sc.OLD_SUBSCRIPTION_CENTER = su.CENTER
AND sc.OLD_SUBSCRIPTION_ID = su.id
AND sc.NEW_SUBSCRIPTION_CENTER IS NOT NULL
AND CURRENT_DATE BETWEEN TRUNC(sc.EFFECT_DATE) AND COALESCE(TRUNC(longtodate
    (sc.CANCEL_TIME)), CURRENT_DATE+1)
LEFT JOIN
    INVOICELINES il
ON
    il.center = su.INVOICELINE_CENTER
AND il.id = su.INVOICELINE_ID
AND il.SUBID = su.INVOICELINE_SUBID
LEFT JOIN
    SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = su.CENTER
AND ss.SUBSCRIPTION_ID = su.ID

WHERE
    p.CENTER IN(:scope)
AND su.LAST_MODIFIED >= PARAMS.FROMDATE
AND su.LAST_MODIFIED < PARAMS.TODATE