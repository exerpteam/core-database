SELECT
    biview."SALES_LINE_ID",
    biview."SUBSCRIPTION_ID"
FROM
    (
        SELECT
            sil.INVOICELINE_CENTER||'inv'||sil.INVOICELINE_ID||'ln'||sil.INVOICELINE_SUBID AS "SALES_LINE_ID",
            spp.CENTER||'ss'||spp.id                                                       AS "SUBSCRIPTION_ID",
            GREATEST(spp.CANCELLATION_TIME,spp.ENTRY_TIME)                                 AS "ETS"
        FROM
            SUBSCRIPTIONPERIODPARTS spp
        JOIN
            SPP_INVOICELINES_LINK sil
        ON
            sil.PERIOD_CENTER = spp.CENTER
            AND sil.PERIOD_ID = spp.id
            AND sil.PERIOD_SUBID = spp.SUBID) biview
WHERE
    biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000
UNION ALL
SELECT
    biview."SALES_LINE_ID",
    biview."SUBSCRIPTION_ID"
FROM
    (
        SELECT
            cl.center||'cred'||cl.id||'cnl'||cl.subid      AS "SALES_LINE_ID",
            spp.CENTER||'ss'||spp.id                       AS "SUBSCRIPTION_ID",
            GREATEST(spp.CANCELLATION_TIME,spp.ENTRY_TIME) AS "ETS"
        FROM
            CREDIT_NOTE_LINES_MT CL
        JOIN
            SPP_INVOICELINES_LINK sil
        ON
            sil.INVOICELINE_CENTER = cl.INVOICELINE_CENTER
            AND sil.INVOICELINE_ID = cl.INVOICELINE_ID
            AND sil.INVOICELINE_SUBID = cl.INVOICELINE_SUBID
        JOIN
            SUBSCRIPTIONPERIODPARTS spp
        ON
            sil.PERIOD_CENTER = spp.CENTER
            AND sil.PERIOD_ID = spp.id
            AND sil.PERIOD_SUBID = spp.SUBID) biview
WHERE
    biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000