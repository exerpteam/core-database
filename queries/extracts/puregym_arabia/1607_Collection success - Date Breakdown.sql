SELECT
    pr.REQ_DATE,
    ch.name AS clearinghouseName,
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
            THEN 1
            ELSE 0
        END) AS "Submitted",
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                AND pr.state = 3
            THEN 1
            ELSE 0
        END) AS "Paid",
    CASE
        WHEN SUM (
                CASE
                    WHEN pr.state = 3
                    THEN 1
                    ELSE 0
                END)<> 0
        THEN TO_CHAR(SUM(
                CASE
                    WHEN pr.state = 3
                    THEN 1
                    ELSE 0
                END) * 100 / COUNT(*), 'FM999.00') || ' %'
        ELSE '0 %'
    END AS "Success ratio"
FROM
    PAYMENT_REQUESTS pr
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pr.CENTER = pag.center
    AND pr.id = pag.id
    AND pr.AGR_SUBID = pag.subid
JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pag.CLEARINGHOUSE
LEFT JOIN
    invoice_lines_mt il
ON
    il.center = pr.COLL_FEE_INVLINE_CENTER
    AND il.id = pr.COLL_FEE_INVLINE_ID
    AND il.subid = pr.COLL_FEE_INVLINE_SUBID
WHERE
    pr.REQ_DATE >= $$FromDate$$
    AND pr.req_date <= $$ToDate$$
    AND pr.REQUEST_TYPE = 1
    AND pr.CENTER IN ($$Scope$$)
    AND ( (
            'ALL' = $$ClearinghouseName$$)
        OR (
            ch.name = $$ClearinghouseName$$) )
GROUP BY
    pr.REQ_DATE,
    ch.name
ORDER BY
    pr.REQ_DATE