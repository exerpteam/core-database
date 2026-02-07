SELECT
    c.NAME,
    SUM(
        CASE
            WHEN art.collected =1 and spp.SPP_STATE = 1
            THEN 1
            ELSE 0
        END)                                        AS "TOTAL SUCCEEDED",
    COUNT(art.center||'ss'||art.ID||'s'||art.SUBID) AS "Total Sold",
    TO_CHAR(SUM(
        CASE
            WHEN art.collected =1 and spp.SPP_STATE = 1
            THEN 1
            ELSE 0
        END) * 100 / COUNT(art.center||'ss'||art.ID||'s'||art.SUBID),'FM999.00')|| ' %' AS "SUCCEDED PERCENTAGE"
FROM
    PUREGYM.SUBSCRIPTIONS s
JOIN
    PUREGYM.SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.id
    AND st.ST_TYPE = 1
JOIN
    PUREGYM.SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = s.CENTER
    AND spp.id = s.ID
    AND spp.SUBID = 1
 
JOIN
    PUREGYM.SPP_INVOICELINES_LINK sil
ON
    sil.PERIOD_CENTER = s.CENTER
    AND sil.PERIOD_ID = s.ID
    AND sil.PERIOD_SUBID = 1
JOIN
    PUREGYM.AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = sil.INVOICELINE_CENTER
    AND art.REF_ID = sil.INVOICELINE_ID
JOIN
    PUREGYM.CENTERS c
ON
    s.OWNER_CENTER = c.id
WHERE
    s.OWNER_CENTER IN ($$scope$$)
    AND s.CREATION_TIME BETWEEN $$start_date$$ AND $$end_date$$
    and c.STARTUPDATE <longtodate($$start_date$$)
GROUP BY
    c.name