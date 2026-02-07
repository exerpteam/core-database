SELECT
    ar.customercenter ||'p'|| ar.customerid AS memberid,
    p.external_id,
    ROUND(ar.balance, 2)                    AS balance,
    CASE ar.AR_TYPE
        WHEN 1
        THEN 'cash_account'
        WHEN 4
        THEN 'payment_account'
        WHEN 5
        THEN 'debt_account'
        WHEN 6
        THEN 'installment_plan_account'
    END             AS ar_type
   
FROM
    account_receivables ar
JOIN
    persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id


WHERE
   (p.external_id) IN (:members)
AND ar.balance < 0
--AND ar.state=0
and ar.center != 6602


GROUP BY
    ar.customercenter,
    ar.customerid,
    ar.balance,
    p.external_id, 
    ar.AR_TYPE