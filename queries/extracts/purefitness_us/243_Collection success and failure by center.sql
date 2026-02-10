-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8560
SELECT
    CASE
        WHEN per_center.name IS NULL
        THEN 'Total'
        ELSE per_center.name
    END     AS "Club Name",
    ch.name AS clearinghouseName,
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
            THEN 1
            ELSE 0
        END) AS "Submitted payments",
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
            THEN pr.REQ_AMOUNT
            ELSE 0
        END) AS "Submitted payments amount",
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                AND pr.state = 3
            THEN 1
            ELSE 0
        END) AS "Paid payments",
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                AND pr.state = 3
            THEN pr.REQ_AMOUNT
            ELSE 0
        END) AS "Paid payments amount",
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
    END AS "Paid payments ratio %",
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                AND pr.state = 17
            THEN 1
            ELSE 0
        END) AS "Failed payments",
    SUM(
        CASE
            WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                AND pr.state = 17
            THEN pr.REQ_AMOUNT
            ELSE 0
        END) AS "Failed payments amount",
    CASE
        WHEN SUM (
                CASE
                    WHEN pr.state = 17
                    THEN 1
                    ELSE 0
                END)<> 0
        THEN TO_CHAR(SUM(
                CASE
                    WHEN pr.state = 17
                    THEN 1
                    ELSE 0
                END) * 100 / COUNT(*), 'FM999.00') || ' %'
        ELSE '0 %'
    END AS "Failed payments ratio %"
FROM
    payment_requests pr
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
JOIN
    centers per_center
ON
    per_center.id = pr.center
LEFT JOIN
    invoice_lines_mt il
ON
    il.center = pr.coll_fee_invline_center
    AND il.id = pr.coll_fee_invline_id
    AND il.subid = pr.coll_fee_invline_subid
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
    grouping sets ( (per_center.name, ch.name), ())