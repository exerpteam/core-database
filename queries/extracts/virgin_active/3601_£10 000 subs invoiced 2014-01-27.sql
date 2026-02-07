SELECT
    invl.PERSON_CENTER || 'p' || invl.PERSON_ID pid,
    spp.CENTER || 'ss' || spp.id                sid,
    invl.TOTAL_AMOUNT,
    spp.TO_DATE -                                                          spp.FROM_DATE,
    ROUND(NVL(invl.TOTAL_AMOUNT,1) / NVL(spp.TO_DATE+1 - spp.FROM_DATE,1)) price_per_day
FROM
    SUBSCRIPTIONPERIODPARTS spp
JOIN
    SPP_INVOICELINES_LINK link
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID = spp.SUBID
JOIN
    INVOICELINES invl
ON
    invl.CENTER = link.INVOICELINE_CENTER
    AND invl.ID = link.INVOICELINE_ID
    AND invl.SUBID = link.INVOICELINE_SUBID
WHERE
    spp.ENTRY_TIME BETWEEN 1422313200000 AND 1422399600000
ORDER BY
    ROUND(NVL(invl.TOTAL_AMOUNT,1) / NVL(spp.TO_DATE+1 - spp.FROM_DATE,1)) DESC