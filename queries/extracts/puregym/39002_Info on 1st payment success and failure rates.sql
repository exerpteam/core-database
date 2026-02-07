-- Parameters: scope(SCOPE),FromDate(DATE),ToDate(DATE)
SELECT
    DECODE(per_center.name, NULL, '--Total', per_center.name) AS "Club Name",
    SUM(
        CASE
            WHEN first_pr.state IN (3,
                                    17)
            THEN 1
            ELSE 0
        END)                 AS "Submitted payments",
    SUM(first_pr.req_amount) AS "Submitted payments amount",
    SUM(
        CASE
            WHEN first_pr.state = 3
            THEN 1
            ELSE 0
        END) AS "Paid payments",
    SUM(
        CASE
            WHEN first_pr.state = 3
            THEN first_pr.req_amount
            ELSE 0
        END) AS "Paid payments amount",
    CASE
        WHEN SUM (
                CASE
                    WHEN first_pr.state = 3
                    THEN 1
                    ELSE 0
                END)<> 0
        THEN TO_CHAR(SUM(
                CASE
                    WHEN first_pr.state = 3
                    THEN 1
                    ELSE 0
                END) * 100 / COUNT(*), 'FM999.00') || ' %'
        ELSE '0 %'
    END AS "Payed payments ratio %",
    SUM(
        CASE
            WHEN first_pr.state = 17
            THEN 1
            ELSE 0
        END) AS "Failed payments",
    SUM(
        CASE
            WHEN first_pr.state = 17
            THEN first_pr.req_amount
            ELSE 0
        END) AS "Failed payments amount",
    CASE
        WHEN SUM (
                CASE
                    WHEN first_pr.state = 17
                    THEN 1
                    ELSE 0
                END)<> 0
        THEN TO_CHAR(SUM(
                CASE
                    WHEN first_pr.state = 17
                    THEN 1
                    ELSE 0
                END) * 100 / COUNT(*), 'FM999.00') || ' %'
        ELSE '0 %'
    END AS "Failed payments ratio %"
FROM
    (
        SELECT
            p.center  AS personCenter,
            p.id      AS personId,
            pr.center AS prCenter,
            pr.id     AS prId,
            pr.subid,
            TRUNC(pr.req_date) AS req_date,
            pr.req_amount,
            pr.state,
            CASE
                WHEN FIRST_VALUE(pr.req_date) OVER (PARTITION BY p.center, p.id ORDER BY pr.req_date RANGE UNBOUNDED PRECEDING) = pr.req_date
                THEN 'First'
                ELSE 'Remain'
            END AS prFlag
        FROM
            persons p
        JOIN
            persons allp
        ON
            allp.current_person_center = p.center
            AND allp.current_person_id = p.id
        JOIN
            account_receivables ar
        ON
            ar.customercenter = allp.center
            AND ar.customerid = allp.id
        JOIN
            payment_requests pr
        ON
            pr.center = ar.center
            AND pr.id = ar.id
        WHERE
            ar.ar_type = 4
            AND pr.REQUEST_TYPE = 1
            AND p.CENTER IN ($$scope$$) )first_pr
JOIN
    centers per_center
ON
    per_center.id = first_pr.personCenter
WHERE
    first_pr.prFlag = 'First'
    AND first_pr.state IN (3, 17)
    AND first_pr.req_date >= $$FromDate$$
    AND first_pr.req_date <= $$ToDate$$
GROUP BY
    grouping sets ( (per_center.name), ())