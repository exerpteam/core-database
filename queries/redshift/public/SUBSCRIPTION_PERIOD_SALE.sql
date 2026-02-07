SELECT
    sil.PERIOD_CENTER||'ss'||sil.PERIOD_ID||'spp'||sil.PERIOD_SUBID     AS "SUBSCRIPTION_PERIOD_ID",
    sil.INVOICELINE_CENTER||'inv'||sil.INVOICELINE_ID||'ln'||sil.INVOICELINE_SUBID AS "SALE_LOG_ID",
    i.center     AS "CENTER_ID",
    i.entry_time AS "ETS"
FROM
    SPP_INVOICELINES_LINK sil
JOIN
    invoices i 
ON
    i.center = sil.invoiceline_center
AND i.id = sil.invoiceline_id
