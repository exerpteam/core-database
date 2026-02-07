SELECT
    CASE
        WHEN per_center.name IS NULL
        THEN 'Total'
        ELSE per_center.name
    END         AS "Club Name",
    pr.REQ_DATE AS "Request Date",
    pr.xfr_info AS "Rejected Reason",
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
        END) AS "Failed payments amount"
FROM
    payment_requests pr
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
    AND pr.rejected_reason_code IS NOT NULL
GROUP BY
    grouping sets ( (per_center.name, pr.REQ_DATE, pr.xfr_info), ())
ORDER BY
    per_center.name,
    pr.REQ_DATE