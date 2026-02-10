-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    SUM(
        CASE
            WHEN coalesce(prs.rejection_fee, 0) > 0
            THEN 1
            ELSE 0
        END) AS "Submitted Bounce fees",
SUM(
        CASE
            WHEN coalesce(prs.rejection_fee, 0) > 0
            THEN prs.rejection_fee
            ELSE 0
        END) AS "Submitted  £",
    SUM(
        CASE
            WHEN coalesce(prs.rejection_fee, 0) > 0
                AND pr.state  in( 3,4)
            THEN 1
            ELSE 0
        END) AS "Paid Bounce fees",
    SUM(
        CASE
            WHEN coalesce(prs.rejection_fee, 0) > 0
                AND pr.state in( 3,4)
            THEN prs.rejection_fee
            ELSE 0
        END) AS "Paid Bounce fees total £",
    CASE
        WHEN SUM (
                CASE
                    WHEN (coalesce(prs.rejection_fee,0) > 0
                            AND pr.state in( 3,4))
                    THEN 1
                    ELSE 0
                END)> 0
        THEN TO_CHAR(SUM(
                CASE
                    WHEN coalesce(prs.rejection_fee, 0) > 0
                        AND pr.state in( 3,4)
                    THEN 1
                    ELSE 0
                END) * 100/ SUM(
                CASE
                    WHEN coalesce(prs.rejection_fee,0) > 0
                    THEN 1
                    ELSE 0
                END), 'FM999.00') || ' %'
        ELSE '0 %'
    END AS "Bounces success ratio" ,
    SUM(
        CASE
            WHEN coalesce(prs.rejection_fee,0) = 0
            THEN 1
            ELSE 0
        END) AS "Submitted Free Bounce fees",
    SUM(
        CASE
            WHEN coalesce(prs.rejection_fee,0) = 0
                AND pr.state in( 3,4)
            THEN 1
            ELSE 0
        END) AS "Paid Free Bounce fees",
    CASE
        WHEN SUM (
                CASE
                    WHEN (coalesce(prs.rejection_fee,0) = 0
                            AND pr.state in( 3,4))
                    THEN 1
                    ELSE 0
                END)<> 0
        THEN TO_CHAR(SUM(
                CASE
                    WHEN coalesce(prs.rejection_fee,0) = 0
                        AND pr.state in( 3,4)
                    THEN 1
                    ELSE 0
                END) * 100/ SUM(
                CASE
                    WHEN coalesce(prs.rejection_fee,0) = 0
                    THEN 1
                    ELSE 0
                END), 'FM999.00') || ' %'
        ELSE '0 %'
    END AS "Free Bounces success ratio"
FROM
    PAYMENT_REQUESTS pr
join payment_request_specifications prs on  pr.inv_coll_center = prs.center
AND pr.inv_coll_id = prs.id
AND pr.inv_coll_subid = prs.subid
WHERE
    pr.REQ_DATE >= $$FromDate$$
    AND pr.req_date <= $$ToDate$$
    AND pr.REQUEST_TYPE = 6 --Representation
   AND pr.CENTER IN ($$Scope$$)
and pr.state not in (8,12)