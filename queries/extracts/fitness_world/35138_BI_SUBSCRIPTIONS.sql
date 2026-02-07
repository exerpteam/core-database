-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    cp.EXTERNAL_ID                                                   "PERSON_ID",
    s.CENTER || 'ss' || s.ID                                         "SUBSCRIPTION_ID",
    s.CENTER                                                         "SUBSCRIPTION_CENTER",
    BI_DECODE_FIELD ('SUBSCRIPTIONS','STATE',s.STATE)         AS     "STATE",
    BI_DECODE_FIELD ('SUBSCRIPTIONS','SUB_STATE',s.SUB_STATE) AS     "SUB_STATE",
    BI_DECODE_FIELD('SUBSCRIPTIONTYPES','ST_TYPE',st.ST_TYPE)        "RENEWAL_TYPE",
    s.SUBSCRIPTIONTYPE_CENTER || 'prod' || s.SUBSCRIPTIONTYPE_ID     "PRODUCT_ID",
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                              "START_DATE",
    TO_CHAR(longtodateC(scStop.CHANGE_TIME, s.CENTER), 'YYYY-MM-DD') "STOP_DATE",
    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                                "END_DATE",
    TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')                       "BILLED_UNTIL_DATE",
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD')                        "BINDING_END_DATE",
    TO_CHAR(longtodateC(s.CREATION_TIME, s.CENTER), 'YYYY-MM-DD')    "CREATION_DATE",
    REPLACE(REPLACE(REPLACE(TO_CHAR(s.SUBSCRIPTION_PRICE, 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')  AS "SUBSCRIPTION_PRICE",
    REPLACE(REPLACE(REPLACE(TO_CHAR(s.BINDING_PRICE, 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')  AS "BINDING_PRICE",
    CASE
        WHEN st.IS_ADDON_SUBSCRIPTION = 0
        THEN 'FALSE'
        WHEN st.IS_ADDON_SUBSCRIPTION = 1
        THEN 'TRUE'
    END AS "REQUIRES_MAIN",
    CASE
        WHEN s.IS_PRICE_UPDATE_EXCLUDED = 0
        THEN 'FALSE'
        WHEN s.IS_PRICE_UPDATE_EXCLUDED = 1
        THEN 'TRUE'
    END AS "SUB_PRICE_UPDATE_EXCLUDED",
    CASE
        WHEN st.IS_ADDON_SUBSCRIPTION = 0
        THEN 'FALSE'
        WHEN st.IS_ADDON_SUBSCRIPTION = 1
        THEN 'TRUE'
    END AS "TYPE_PRICE_UPDATE_EXCLUDED",
    CASE
        WHEN FREEZEPERIODPRODUCT_CENTER IS NOT NULL
        THEN st.FREEZEPERIODPRODUCT_CENTER || 'prod' || st.FREEZEPERIODPRODUCT_ID
        ELSE NULL
    END "FREEZE_PERIOD_PRODUCT_ID",
    CASE
        WHEN s.TRANSFERRED_CENTER IS NOT NULL
        THEN s.TRANSFERRED_CENTER || 'ss' || s.TRANSFERRED_ID
        ELSE NULL
    END "TRANSFERRED_TO",
    CASE
        WHEN s.EXTENDED_TO_CENTER IS NOT NULL
        THEN s.EXTENDED_TO_CENTER || 'ss' || s.EXTENDED_TO_ID
        ELSE NULL
    END                                                                                                         "EXTENDED_TO",
    CASE st.PERIODUNIT  WHEN 0 THEN  'Week'  WHEN 1 THEN  'Days'  WHEN 2 THEN  'Month'  WHEN 3 THEN  'Year'  WHEN 4 THEN  'Hour'  WHEN 5 THEN  'Minutes'  WHEN 6 THEN  'Second' END AS "PERIOD_UNIT",
    REPLACE(TO_CHAR(st.PERIODCOUNT,'FM999G999G999G999G999'),',','.')                                         AS "PERIOD_COUNT",
    s.CENTER                                                                                                 AS "CENTER_ID",
    REPLACE(TO_CHAR(s.LAST_MODIFIED,'FM999G999G999G999G999'),',','.')                                        AS "ETS"
FROM
    PARAMS,
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    persons cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    SUBSCRIPTION_CHANGE scStop
ON
    scStop.OLD_SUBSCRIPTION_CENTER = s.CENTER
    AND scStop.OLD_SUBSCRIPTION_ID = s.ID
    AND scStop.TYPE = 'END_DATE'
    AND scStop.CANCEL_TIME IS NULL
WHERE
    s.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
