WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
            AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day',
            'YYYY-MM-DD')) AS BIGINT) AS todate,
            c.id                      AS centerid
        FROM
            centers c
    )
SELECT
    p.center ||'p'|| p.id                                                 AS memberid,
    p.external_id                                                         AS externalId,
    ccje.step                                                             AS step,
    TO_CHAR(longtodateC(ccje.creationtime,params.centerid), 'YYYY-MM-dd') AS "date",
    COALESCE(ar_payment.balance, 0)                                       AS Payment_Account_Balance,
    COALESCE(ar_ext_debt.balance, 0)                                      AS External_Debt_Account_Balance
FROM
    cashcollectionjournalentries ccje
JOIN
    cashcollectioncases cc
ON
    cc.center = ccje.center
AND cc.id = ccje.id
JOIN
    persons p
ON
    p.center = cc.personcenter
AND p.id = cc.personid
JOIN
    params
ON
    params.centerid = ccje.center
LEFT JOIN
    account_receivables ar_payment
ON
    p.center = ar_payment.customercenter
AND p.id= ar_payment.customerid    
AND ar_payment.ar_type = 4
AND ar_payment.state = 0 --Active
LEFT JOIN
    account_receivables ar_ext_debt
ON
    p.center = ar_ext_debt.customercenter
AND p.id= ar_ext_debt.customerid    
AND ar_ext_debt.ar_type = 5
AND ar_ext_debt.state = 0 --Active
WHERE
    ccje.step IN (:last_step_no)  
AND p.sex != 'C'
AND ccje.creationtime BETWEEN params.fromdate AND params.todate