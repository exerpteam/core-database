WITH
    params AS MATERIALIZED
    (
        SELECT
            TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS todays_date,
            c.id                                      AS center_id
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
SELECT
    p.center || 'p' || p.id   AS PERSONID,
    SUM(art.unsettled_amount) AS overdueamount
FROM
    persons p
JOIN
    params
ON
    params.center_id = p.center
JOIN
    account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 4
JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
LEFT JOIN
    cashcollectioncases ccc
ON
    ccc.personcenter = p.center
AND ccc.personid = p.id
AND ccc.missingpayment = false
AND ccc.closed = false
LEFT JOIN
    account_receivables eda
ON
    p.center = eda.customercenter
AND p.id = eda.customerid
AND eda.ar_type = 5
AND eda.balance <> 0
WHERE
    p.status IN (1,3)
AND ar.balance < 0
AND ccc.center IS NULL
AND eda.center IS NULL
AND EXISTS
    (
        SELECT
            1
        FROM
            payment_requests pr
        WHERE
            pr.center = ar.center
        AND pr.id = ar.id
        AND pr.state NOT IN (1,2,3,4,8))
AND art.status NOT IN ('CLOSED', 'LEGACY')
AND art.amount < 0
AND art.due_date IS NOT NULL
AND art.due_date < params.todays_date
GROUP BY
    p.center,
    p.id