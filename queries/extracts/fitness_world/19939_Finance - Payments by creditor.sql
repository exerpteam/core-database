-- This is the version from 2026-02-05
--  
SELECT
    CREDITOR_ID,
    xfr_delivery fil,
    TO_CHAR(xfr_date, 'YYYY-MM-DD') dato,
    COUNT(*) antal,
    SUM(total) amount
FROM
    (
        SELECT
            pr.CREDITOR_ID,
            pr.XFR_DATE,
            pr.XFR_DELIVERY,
            pr.XFR_AMOUNT total
        FROM
            FW.PAYMENT_REQUESTS pr
        WHERE
            pr.XFR_DATE >= :FROMDATE
            AND pr.XFR_DATE <= :TODATE
            AND pr.STATE in (3,4)
        UNION ALL
        SELECT
            up.XFR_CREDITOR_ID CREDITOR_ID,
            up.XFR_DATE,
            up.XFR_DELIVERY,
            up.XFR_AMOUNT total
        FROM
            FW.UNPLACED_PAYMENTS up
        WHERE
            up.XFR_DATE >= :FROMDATE
            AND up.XFR_DATE <= :TODATE
)
GROUP BY
    CREDITOR_ID,
    xfr_delivery,
    xfr_date
ORDER BY
    CREDITOR_ID,
    xfr_date