-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
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
    s.LAST_MODIFIED                                                                                             "ETS"
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
LEFT JOIN
    SUBSCRIPTION_CHANGE scStop
ON
    scStop.OLD_SUBSCRIPTION_CENTER = s.CENTER
    AND scStop.OLD_SUBSCRIPTION_ID = s.ID
    AND scStop.TYPE = 'END_DATE'
    AND scStop.CANCEL_TIME IS NULL) biview
