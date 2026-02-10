-- The extract is extracted from Exerp on 2026-02-08
-- EC-3019
WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )
SELECT distinct
    biview.PERSON_ID,
       biview.SUBSCRIPTION_ID,
       biview.SUBSCRIPTION_CENTER,
       biview.STATE,
       biview.SUB_STATE,
       biview.RENEWAL_TYPE,
       biview.PRODUCT_ID,
       biview.START_DATE,
       biview.STOP_DATE,
       biview.END_DATE,
       biview.BILLED_UNTIL_DATE,
       biview.BINDING_END_DATE,
       biview.CREATION_DATE,
       biview.SUBSCRIPTION_PRICE,
       biview.BINDING_PRICE,
       biview.REQUIRES_MAIN,
       biview.SUB_PRICE_UPDATE_EXCLUDED,
       biview.TYPE_PRICE_UPDATE_EXCLUDED,
       biview.FREEZE_PERIOD_PRODUCT_ID,
       biview.TRANSFERRED_TO,
       biview.EXTENDED_TO,
       biview.PERIOD_UNIT,
       biview.PERIOD_COUNT,
       biview.CENTER_ID,
       biview.ETS
FROM
    params,
    (SELECT
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
    s.SUBSCRIPTION_PRICE AS                                          "SUBSCRIPTION_PRICE",
    s.BINDING_PRICE      AS                                          "BINDING_PRICE",
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
    DECODE(st.PERIODUNIT, 0, 'Week', 1, 'Days', 2, 'Month', 3, 'Year', 4, 'Hour', 5, 'Minutes', 6, 'Second') AS "PERIOD_UNIT",
    st.PERIODCOUNT                                                                                           AS "PERIOD_COUNT",
    s.CENTER                                                                                                 AS "CENTER_ID",
    s.LAST_MODIFIED                                                                                             "ETS",
row_number() over (partition by s.CENTER, s.ID order by scStop.CHANGE_TIME desc) as RowN
FROM
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
cross join params

LEFT JOIN
    SUBSCRIPTION_CHANGE scStop
ON
    scStop.OLD_SUBSCRIPTION_CENTER = s.CENTER
    AND scStop.OLD_SUBSCRIPTION_ID = s.ID
    AND scStop.TYPE = 'END_DATE'
    AND scStop.CANCEL_TIME IS NULL
) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
AND rowN=1
