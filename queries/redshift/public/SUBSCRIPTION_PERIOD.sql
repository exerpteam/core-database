SELECT
    spp.CENTER||'ss'||spp.id||'spp'||spp.SUBID AS "ID",
    spp.CENTER||'ss'||spp.id                   AS "SUBSCRIPTION_ID",
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
        WHEN spp.SPP_TYPE = 9
        THEN 'PRORATA'
        ELSE 'UNKNOWN'
    END AS "TYPE",
    CASE
        WHEN spp.SPP_STATE = 1
        THEN 'ACTIVE'
        WHEN spp.SPP_STATE = 2
        THEN 'CANCELLED'
        ELSE 'UNKNOWN'
    END           AS "STATE",
    spp.FROM_DATE AS "FROM_DATE",
    spp.TO_DATE   AS "TO_DATE",
    CASE
        WHEN spp.CANCELLATION_TIME = 0
        THEN NULL
        ELSE spp.CANCELLATION_TIME
    END                                                                  AS "CANCELLATION_DATETIME",
    sil.INVOICELINE_CENTER||'inv'||sil.INVOICELINE_ID||'ln'||sil.INVOICELINE_SUBID AS "SALE_LOG_ID"
    ,
    spp.center                                     AS "CENTER_ID",
    GREATEST(spp.CANCELLATION_TIME,spp.ENTRY_TIME) AS "ETS"
FROM
    SUBSCRIPTIONPERIODPARTS spp
JOIN
    SPP_INVOICELINES_LINK sil
ON
    sil.PERIOD_CENTER = spp.CENTER
AND sil.PERIOD_ID = spp.id
AND sil.PERIOD_SUBID = spp.SUBID
