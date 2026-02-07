/*
 * -----------------------------------------------------------------------
 * Exerp Data Sync - Subscriptions Data - Incremental
 * -----------------------------------------------------------------------
 * Description: 
 * Extract ID: 2216
 * Source System: 
 * -----------------------------------------------------------------------
 */

WITH
    params AS materialized
    (
        SELECT
             id   AS  center,
            CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')-interval '3' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS FROMDATE,
            CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')+interval '1' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS TODATE,
             'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
        FROM
            centers c
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
        JOIN 
            PRODUCTS p
        ON ppgl.product_id = p.id
            AND ppgl.product_center = p.center
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = 1
        AND NOT p.globalid in ('DAY_PASS')
    )   
SELECT DISTINCT
    np.EXTERNAL_ID                                                              AS "EXTERNALID",
    su.center||'ss'||su.id                                                      AS "SUBSCRIPTIONID",
    su.START_DATE                                                               AS "STARTDATE",
    su.END_DATE                                                                 AS "ENDDATE",
    su.SUBSCRIPTIONTYPE_CENTER || 'prod' || su.SUBSCRIPTIONTYPE_ID              AS "PRODUCTID",
    COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)) AS "CURRENTPRICE",
    COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)                                   AS "NORMALPRICE",
    TO_CHAR(longtodatec(su.CREATION_TIME, su.center) , 'YYYY-MM-DD')            AS "MEMBERSIGNUPDATE",
    il.TOTAL_AMOUNT                                                             AS "PRICEJFEE",
    CASE
        WHEN il.TOTAL_AMOUNT < il.PRODUCT_NORMAL_PRICE
        THEN 1
        ELSE 0
    END AS "DISCOUNTEDJFEE",
    CASE
        WHEN ss.PRICE_ADMIN_FEE IS NULL
        THEN 0
        WHEN ss.PRICE_ADMIN_FEE = 0
        THEN 0
        ELSE 1
    END AS "PAIDCHARITYDONATION",
    CASE su.state
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
    END AS "STATE" ,
    CASE su.sub_state
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
    END AS "SUBSTATE" ,
    CASE
        WHEN sc.NEW_SUBSCRIPTION_CENTER IS NOT NULL
        THEN sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID
        ELSE NULL
    END                                                                      AS "NEWSUBSCRIPTIONID",
    TO_CHAR(longtodatec(su.LAST_MODIFIED,su.center),params.DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
FROM
    PERSONS p
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
    SUBSCRIPTIONPERIODPARTS SPP
ON
    (
        SPP.CENTER = SU.CENTER
        AND SPP.ID = SU.ID
        AND SPP.FROM_DATE <= greatest(CAST(now() AS DATE), su.start_date)
        AND (
            SPP.TO_DATE IS NULL
            OR SPP.TO_DATE >= greatest(CAST(now() AS DATE), su.start_date) )
        AND SPP.SPP_STATE = 1
        AND SPP.ENTRY_TIME < CAST(datetolongC(TO_CHAR(CAST(now() AS DATE)+1, 'YYYY-MM-DD HH24:MI'), spp.center) AS BIGINT))
LEFT JOIN
    SUBSCRIPTION_PRICE SP
ON
    (
        SP.SUBSCRIPTION_CENTER = SU.CENTER
        AND SP.SUBSCRIPTION_ID = SU.ID
        AND sp.CANCELLED = 0
        AND SP.FROM_DATE <= greatest(CAST(now() AS DATE), su.start_date)
        AND (
            SP.TO_DATE IS NULL
            OR SP.TO_DATE >= greatest(CAST(now() AS DATE), su.start_date) ) )
LEFT JOIN
    SUBSCRIPTION_CHANGE sc
ON
    sc.OLD_SUBSCRIPTION_CENTER = su.CENTER
    AND sc.OLD_SUBSCRIPTION_ID = su.id
    AND sc.NEW_SUBSCRIPTION_CENTER IS NOT NULL
    AND CAST(now() AS DATE) BETWEEN TRUNC(sc.EFFECT_DATE) AND TRUNC(COALESCE(longtodatec(sc.CANCEL_TIME, su.center), CAST(now() AS DATE)+1))
LEFT JOIN
    invoice_lines_mt il
ON
    il.center = su.INVOICELINE_CENTER
    AND il.id = su.INVOICELINE_ID
    AND il.SUBID = su.INVOICELINE_SUBID
LEFT JOIN
    SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = su.CENTER
    AND ss.SUBSCRIPTION_ID = su.ID
JOIN
    PARAMS
ON
    PARAMS.center = p.center
WHERE
    p.center in (:scope)
    AND su.LAST_MODIFIED >= PARAMS.FROMDATE
    AND su.LAST_MODIFIED < PARAMS.TODATE
UNION ALL
     SELECT 
        NULL AS "EXTERNALID",
        NULL AS "SUBSCRIPTIONID",
        NULL AS "STARTDATE",
        NULL AS "ENDDATE",
        NULL AS "PRODUCTID",
        NULL AS "CURRENTPRICE",
        NULL AS "NORMALPRICE",
        NULL AS "MEMBERSIGNUPDATE",
        NULL AS "PRICEJFEE",
        NULL AS "DISCOUNTEDJFEE",
        NULL AS "PAIDCHARITYDONATION",
        NULL AS "Subscription State",
        NULL AS "Subscription Sub State",
        NULL AS "NEWSUBSCRIPTIONID",
        NULL AS "LASTMODIFIEDDATE"