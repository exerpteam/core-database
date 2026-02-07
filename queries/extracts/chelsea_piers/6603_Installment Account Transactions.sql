SELECT
    p.center || 'p' || p.id                 AS PersonId,
    ar.balance                              AS InstallmentAccountBalance,
    longtodatec(art.trans_time, art.center) AS TransTimeDate,
    art.amount,
    art.due_date,
    art.text,
    art.status,
    art.unsettled_amount,
    debit_ac.name AS Debit_Account_Name,
    credit_ac.name AS Credit_Account_Name
FROM
    chelseapiers.persons p
JOIN
    chelseapiers.account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 6
AND ar.state = 0
JOIN
    chelseapiers.ar_trans art
ON
    ar.center = art.center
    AND ar.id = art.id
LEFT JOIN chelseapiers.account_trans act
        ON
        art.ref_center = act.center
        AND art.ref_id = act.id
        AND art.ref_subid = act.subid
LEFT JOIN chelseapiers.accounts debit_ac
        ON
                debit_ac.center = act.debit_accountcenter
                AND debit_ac.id = act.debit_accountid
LEFT JOIN chelseapiers.accounts credit_ac
        ON
                credit_ac.center = act.credit_accountcenter
                AND credit_ac.id = act.credit_accountid
WHERE
        art.ref_type = 'ACCOUNT_TRANS'
UNION ALL
SELECT
    DISTINCT
    p.center || 'p' || p.id                 AS PersonId,
    ar.balance                              AS InstallmentAccountBalance,
    longtodatec(art.trans_time, art.center) AS TransTimeDate,
    art.amount,
    art.due_date,
    art.text,
    art.status,
    art.unsettled_amount,
    debit_ac.name AS Debit_Account_Name,
    credit_ac.name AS Credit_Account_Name
FROM
    chelseapiers.persons p
JOIN
    chelseapiers.account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 6
AND ar.state = 0
JOIN
    chelseapiers.ar_trans art
ON
    ar.center = art.center
    AND ar.id = art.id
LEFT JOIN chelseapiers.credit_note_lines_mt cn
        ON
                cn.center = art.ref_center
                AND cn.id = art.ref_id
LEFT JOIN chelseapiers.account_trans act
        ON
                act.center = cn.account_trans_center
                AND act.id = cn.account_trans_id
                AND act.subid = cn.account_trans_subid
LEFT JOIN chelseapiers.accounts debit_ac
        ON
                debit_ac.center = act.debit_accountcenter
                AND debit_ac.id = act.debit_accountid
LEFT JOIN chelseapiers.accounts credit_ac
        ON
                credit_ac.center = act.credit_accountcenter
                AND credit_ac.id = act.credit_accountid
WHERE
        art.ref_type = 'CREDIT_NOTE'