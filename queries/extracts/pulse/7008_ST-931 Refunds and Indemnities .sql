       SELECT
             crt.center As Center_No,
             'DD Member Refunds' AS Category,
             p.center||'p'||p.id AS Member_No,p.fullname AS Member_Name, -crt.amount AS Amount,longtodate(crt.transtime) As Transaction_Date
             ,art.employeecenter||'emp'||art.employeeid as EmployeeID
         FROM
             CASHREGISTERTRANSACTIONS crt
         JOIN
             AR_TRANS art
         ON
             art.CENTER = crt.ARTRANSCENTER
             AND art.ID = crt.ARTRANSID
             AND art.SUBID = crt.ARTRANSSUBID
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.center = art.center
             AND ar.id = art.id
             AND ar.AR_TYPE = 4
         JOIN
             PERSONS p
         ON
             p.center = crt.customercenter
             and p.id = crt.customerid
         WHERE
             crt.center in (:Scope)
             AND crt.TRANSTIME >=  :From_Date
             AND crt.TRANSTIME  < :To_Date + 24 * 60 * 60 * 1000
             AND crt.AMOUNT > 0
             AND crt.crttype IN (4,18)
  UNION ALL
         SELECT
             crt.center,
             'Arrears Payments' AS text,
             p.center||'p'||p.id,p.fullname, crt.amount,longtodate(crt.transtime),art.employeecenter||'emp'||art.employeeid as EmployeeID
         FROM
             PULSE.CASHREGISTERTRANSACTIONS crt
         JOIN
             PULSE.AR_TRANS art
         ON
             art.CENTER = crt.ARTRANSCENTER
             AND art.ID = crt.ARTRANSID
             AND art.SUBID = crt.ARTRANSSUBID
         JOIN
             PULSE.ACCOUNT_RECEIVABLES ar
         ON
             ar.center = art.center
             AND ar.id = art.id
             AND ar.AR_TYPE = 4
         JOIN
             PERSONS p
         ON
             p.center = crt.customercenter
             and p.id = crt.customerid
         WHERE
             crt.center in (:Scope)
             AND crt.TRANSTIME >=  :From_Date
             AND crt.TRANSTIME  < :To_Date + 24 * 60 * 60 * 1000
             AND crt.AMOUNT > 0
             AND crt.crttype NOT IN (4,18,2)
             AND art.TEXT = 'Payment into account'
 UNION ALL
     SELECT
             tr.center,
             CASE
                 WHEN debit.GLOBALID = 'AR_PAYMENT_PERSONS'
                 THEN credit.NAME
                 ELSE debit.name
             END AS text,
                 p.center||'p'||p.id,p.fullname, -tr.amount,longtodate(tr.trans_time),art.employeecenter||'emp'||art.employeeid as EmployeeID
         FROM
             ACCOUNT_TRANS tr
         JOIN
             PULSE.ACCOUNTS credit
         ON
             tr.CREDIT_ACCOUNTCENTER = credit.center
             AND tr.CREDIT_ACCOUNTID = credit.id
         JOIN
             ACCOUNTS debit
         ON
             tr.DEBIT_ACCOUNTCENTER = debit.center
             AND tr.DEBIT_ACCOUNTID = debit.id
         JOIN
             PULSE.AR_TRANS art
         ON
             art.REF_TYPE = 'ACCOUNT_TRANS'
             AND art.REF_CENTER = tr.CENTER
             AND art.REF_ID = tr.ID
             AND art.REF_SUBID = tr.SUBID
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.center = art.center
             AND ar.id = art.id
             AND ar.AR_TYPE = 4
         JOIN
              PERSONS p
         ON
             p.center = ar.customercenter
             and p.id = ar.customerid
         WHERE
             tr.center in (:Scope)
             AND tr.TRANS_TIME >=  :From_Date
             AND tr.TRANS_TIME  < :To_Date + 24 * 60 * 60 * 1000
             AND ((
                     credit.GLOBALID IN ('DDIC',
                                         'DD_ARREARS_HO',
                                         'DD_MEMBER_REFUNDS')
                     AND debit.GLOBALID = 'AR_PAYMENT_PERSONS')
                 OR (
                     debit.GLOBALID IN ('DDIC',
                                        'DD_ARREARS_HO',
                                        'DD_MEMBER_REFUNDS')
                     AND credit.GLOBALID = 'AR_PAYMENT_PERSONS'))
 UNION ALL
     SELECT
             tr.center,
             CASE
                 WHEN debit.GLOBALID = 'AR_CASH'
                 THEN credit.NAME
                 ELSE debit.name
             END AS text,
                 p.center||'p'||p.id,p.fullname, -tr.amount,longtodate(tr.trans_time),art.employeecenter||'emp'||art.employeeid as EmployeeID
         FROM
             ACCOUNT_TRANS tr
         JOIN
             PULSE.ACCOUNTS credit
         ON
             tr.CREDIT_ACCOUNTCENTER = credit.center
             AND tr.CREDIT_ACCOUNTID = credit.id
         JOIN
             ACCOUNTS debit
         ON
             tr.DEBIT_ACCOUNTCENTER = debit.center
             AND tr.DEBIT_ACCOUNTID = debit.id
         JOIN
             PULSE.AR_TRANS art
         ON
             art.REF_TYPE = 'ACCOUNT_TRANS'
             AND art.REF_CENTER = tr.CENTER
             AND art.REF_ID = tr.ID
             AND art.REF_SUBID = tr.SUBID
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.center = art.center
             AND ar.id = art.id
             AND ar.AR_TYPE = 1
         JOIN
              PERSONS p
         ON
             p.center = ar.customercenter
             and p.id = ar.customerid
         WHERE
             tr.center in (:Scope)
             AND art.employeecenter = 100 -- only from head quarter
             AND tr.TRANS_TIME >=  :From_Date
             AND tr.TRANS_TIME  < :To_Date + 24 * 60 * 60 * 1000
             AND ((
                     credit.GLOBALID IN ('DDIC',
                                         'DD_ARREARS_HO',
                                         'DD_MEMBER_REFUNDS')
                     AND debit.GLOBALID = 'AR_CASH')
                 OR (
                     debit.GLOBALID IN ('DDIC',
                                        'DD_ARREARS_HO',
                                        'DD_MEMBER_REFUNDS')
                     AND credit.GLOBALID = 'AR_CASH'))