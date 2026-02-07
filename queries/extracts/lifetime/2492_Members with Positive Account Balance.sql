SELECT
    c.name                                AS Club,
    ar.customercenter||'p'||ar.customerid AS Person_ID ,
    (
        CASE
            WHEN ar.ar_type = 1
            THEN 'Cash Account'
            WHEN ar.ar_type = 4
            THEN 'Payment Account'
            WHEN ar.ar_type = 5
            THEN 'External Debt Account'
            ELSE 'Unknown'
        END)   AS Account_type ,
    ar.balance AS Account_Balance
FROM
    account_receivables ar
JOIN
    centers c
ON
    ar.center=c.id
WHERE
    ar.balance > 0