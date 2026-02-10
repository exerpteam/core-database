-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS Materialized
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI')) AS BIGINT) END AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI')) AS BIGINT) AS TODATE
    )
SELECT
    spp.CENTER||'ss'||spp.id||'id'||spp.SUBID AS "SUBSCRIPTION_PERIOD_ID",
    spp.CENTER||'ss'||spp.id                  AS "SUBSCRIPTION_ID",
    CASE
        WHEN spp.SPP_TYPE = 1
        THEN 'NORMAL'
        WHEN spp.SPP_TYPE = 2
        THEN'UNCONDITIONAL FREEZE'
        WHEN spp.SPP_TYPE = 3
        THEN 'FREE DAYS'
        WHEN spp.SPP_TYPE = 7
        THEN 'CONDITIONAL FREEZE'
        WHEN spp.SPP_TYPE = 8
        THEN 'INITIAL PERIOD'
        ELSE 'UNKNOWN'
    END                                                                            AS "TYPE",
    BI_DECODE_FIELD('SUBSCRIPTIONPERIODPARTS','SPP_STATE',spp.SPP_STATE)           AS "STATE",
    TO_CHAR(spp.FROM_DATE,'yyyy-MM-dd')                                            AS "FROM_DATE",
    TO_CHAR(spp.TO_DATE,'yyyy-MM-dd')                                              AS "TO_DATE",
    sil.INVOICELINE_CENTER||'inv'||sil.INVOICELINE_ID||'ln'||sil.INVOICELINE_SUBID AS "SALES_LINE_ID",
    spp.center                                                                     AS "CENTER_ID",
    TO_CHAR(GREATEST(spp.CANCELLATION_TIME,spp.ENTRY_TIME),'FM999G999G999G999G999') AS "ETS"
FROM
    PARAMS,
    SUBSCRIPTIONPERIODPARTS spp
JOIN
    SPP_INVOICELINES_LINK sil
ON
    sil.PERIOD_CENTER = spp.CENTER
    AND sil.PERIOD_ID = spp.id
    AND sil.PERIOD_SUBID = spp.SUBID
WHERE
    GREATEST(spp.CANCELLATION_TIME,spp.ENTRY_TIME) BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
