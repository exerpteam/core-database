-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolongtz(TO_CHAR(CURRENT_DATE- $$offset$$ , 'YYYY-MM-DD HH24:MI'),
                    c.time_zone)
            END                                                                      AS FROM_DATE,
            datetolongtz(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END AS                                               "PERSON_ID",
    s.CENTER || 'ss' || s.ID                             "SUBSCRIPTIONS.SUBSCRIPTION_ID",
    CAST ( s.CENTER AS VARCHAR(255))                     "SUBSCRIPTIONS.SUBSCRIPTION_CENTER",
    BI_DECODE_FIELD ('SUBSCRIPTIONS','STATE',s.STATE)         AS "SUBSCRIPTIONS.STATE",
    BI_DECODE_FIELD ('SUBSCRIPTIONS','SUB_STATE',s.SUB_STATE) AS "SUBSCRIPTIONS.SUB_STATE",
    BI_DECODE_FIELD('SUBSCRIPTIONTYPES','ST_TYPE',st.ST_TYPE)    "SUBSCRIPTIONS.RENEWAL_TYPE",
    s.REC_CLIPCARD_CLIPS                                      AS "SUBSCRIPTIONS.RECURRING_CLIPS",
    s.SUBSCRIPTIONTYPE_CENTER || 'prod' || s.SUBSCRIPTIONTYPE_ID "SUBSCRIPTIONS.PRODUCT_ID",
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                          "SUBSCRIPTIONS.START_DATE",
    TO_CHAR(longtodatetz(scStop.STOP_CHANGE_TIME, cen.time_zone), 'YYYY-MM-DD')
                                                                   "SUBSCRIPTIONS.STOP_DATE" ,
    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                              "SUBSCRIPTIONS.END_DATE",
    TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')                    "SUBSCRIPTIONS.BILLED_UNTIL_DATE",
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD')                      "SUBSCRIPTIONS.BINDING_END_DATE",
    TO_CHAR(longtodatetz(s.CREATION_TIME, cen.time_zone), 'YYYY-MM-DD') "SUBSCRIPTIONS.CREATION_DATE",
    CAST ( s.SUBSCRIPTION_PRICE AS VARCHAR(255)) AS                "SUBSCRIPTIONS.SUBSCRIPTION_PRICE"
    ,
    CAST ( s.BINDING_PRICE AS VARCHAR(255)) AS "SUBSCRIPTIONS.BINDING_PRICE",
    CASE
        WHEN st.IS_ADDON_SUBSCRIPTION = 0
        THEN 'FALSE'
        WHEN st.IS_ADDON_SUBSCRIPTION = 1
        THEN 'TRUE'
    END AS "SUBSCRIPTIONS.REQUIRES_MAIN",
    CASE
        WHEN s.IS_PRICE_UPDATE_EXCLUDED = 0
        THEN 'FALSE'
        WHEN s.IS_PRICE_UPDATE_EXCLUDED = 1
        THEN 'TRUE'
    END AS "SUBSCRIPTIONS.SUB_PRICE_UPDATE_EXCLUDED",
    CASE
        WHEN st.IS_ADDON_SUBSCRIPTION = 0
        THEN 'FALSE'
        WHEN st.IS_ADDON_SUBSCRIPTION = 1
        THEN 'TRUE'
    END AS "SUBSCRIPTIONS.TYPE_PRICE_UPDATE_EXCLUDED",
    CASE
        WHEN FREEZEPERIODPRODUCT_CENTER IS NOT NULL
        THEN st.FREEZEPERIODPRODUCT_CENTER || 'prod' || st.FREEZEPERIODPRODUCT_ID
        ELSE NULL
    END AS "SUBSCRIPTIONS.FREEZE_PERIOD_PRODUCT_ID",
    CASE
        WHEN s.TRANSFERRED_CENTER IS NOT NULL
        THEN s.TRANSFERRED_CENTER || 'ss' || s.TRANSFERRED_ID
        ELSE NULL
    END AS "SUBSCRIPTIONS.TRANSFERRED_TO",
    CASE
        WHEN s.EXTENDED_TO_CENTER IS NOT NULL
        THEN s.EXTENDED_TO_CENTER || 'ss' || s.EXTENDED_TO_ID
        ELSE NULL
    END AS "SUBSCRIPTIONS.EXTENDED_TO",
    --BI_DECODE_FIELD ('SUBSCRIPTIONTYPES','PERIODUNIT',st.PERIODUNIT) AS "PERIOD_UNIT",
    CASE
        WHEN st.PERIODUNIT = 0
        THEN 'WEEK'
        WHEN st.PERIODUNIT =1
        THEN 'DAY'
        WHEN st.PERIODUNIT = 2
        THEN 'MONTH'
        WHEN st.PERIODUNIT = 3
        THEN 'YEAR'
        WHEN st.PERIODUNIT =4
        THEN 'HOUR'
        WHEN st.PERIODUNIT = 5
        THEN 'MINUTE'
        WHEN st.PERIODUNIT = 6
        THEN 'SECOND'
        ELSE 'UNKNOWN'
    END            AS "SUBSCRIPTIONS.PERIOD_UNIT",
    st.PERIODCOUNT AS "SUBSCRIPTIONS.PERIOD_COUNT",
    CASE
        WHEN s.REASSIGNED_CENTER IS NOT NULL
        THEN s.REASSIGNED_CENTER || 'ss' || s.REASSIGNED_ID
        ELSE NULL
    END                      "SUBSCRIPTIONS.REASIGNED_TO",
    scStop.STOP_PERSON_ID AS "SUBSCRIPTIONS.STOP_PERSON_ID",
    TO_CHAR(longtodatetz(scStop.STOP_CANCEL_TIME, cen.time_zone), 'YYYY-MM-DD')
                                        "SUBSCRIPTIONS.STOP_CANCEL_DATE",
    CAST ( s.CENTER AS VARCHAR(255)) AS "SUBSCRIPTIONS.CENTER_ID",
    TO_CHAR(longtodatetz(s.LAST_MODIFIED, cen.time_zone), 'dd.MM.yyyy HH24:MI:SS')
    "SUBSCRIPTIONS.LAST_UPDATED_EXERP"
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    centers cen
ON
    cen.id = s.CENTER
LEFT JOIN -- Workaround to avoid bug including duplicate scStop entries
    (
        SELECT
            OLD_SUBSCRIPTION_CENTER,
            OLD_SUBSCRIPTION_ID,
            STOP_CHANGE_TIME,
            STOP_CANCEL_TIME,
            STOP_PERSON_ID
        FROM
            (
                SELECT
                    scStop.OLD_SUBSCRIPTION_CENTER,
                    scStop.OLD_SUBSCRIPTION_ID,
                    scStop.CHANGE_TIME AS STOP_CHANGE_TIME,
                    cp.external_id     AS STOP_PERSON_ID,
                    scStop.CANCEL_TIME AS STOP_CANCEL_TIME,
                    rank() over (partition BY scStop.OLD_SUBSCRIPTION_CENTER,
                    scStop.OLD_SUBSCRIPTION_ID ORDER BY scStop.CHANGE_TIME DESC) AS rnk
                FROM
                    SUBSCRIPTION_CHANGE scStop
                JOIN
                    employees emp
                ON
                    emp.center = scStop.EMPLOYEE_CENTER
                AND emp.id = scStop.EMPLOYEE_ID
                JOIN
                    PERSONS p
                ON
                    emp.PERSONCENTER = p.center
                AND emp.PERSONID = p.id
                JOIN
                    persons cp
                ON
                    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
                AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
                WHERE
                    scStop.TYPE = 'END_DATE' ) x
        WHERE
            rnk = 1) scStop
ON
    scStop.OLD_SUBSCRIPTION_CENTER = s.CENTER
AND scStop.OLD_SUBSCRIPTION_ID = s.ID
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
    -- Only subscriptions updated recently
AND s.LAST_MODIFIED > params.FROM_DATE