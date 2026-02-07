WITH params AS MATERIALIZED
(
        SELECT
                GETSTARTOFDAY(CAST (CAST ('2023-09-01' AS DATE) AS TEXT), C.ID) AS FromDate,
                GETENDOFDAY(CAST (CAST ('2023-09-30' AS DATE) AS TEXT), C.ID) AS ToDate,
                c.id
        from centers c	
        where
                c.id = 1	
)
SELECT 
       -- DISTINCT
        TO_CHAR(longtodateC(act.TRANS_TIME, act.center),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME",
        acc.name                                                             AS account,
        CASE
                WHEN (art.amount<0)
                THEN art.amount
                ELSE 0
        END                                                 AS REFUND ,
        p.fullname                                          AS Name,
        act.TEXT                                            AS "Transaction Text",
        ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID             AS PersonId,
        p.CENTER                                            AS CenterID,
        CASE
                WHEN (art.amount>0)
                THEN art.amount
                ELSE 0
        END                                                                  AS PAYMENT,
        TO_CHAR(longtodateC(act.ENTRY_TIME, act.center),'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME"
        
FROM puregym.persons p
JOIN params par ON p.center = par.id
JOIN puregym.account_receivables ar
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
JOIN puregym.ar_trans art        
        ON ar.center = art.center
        AND ar.id = art.id
JOIN puregym.account_trans act
        ON art.ref_center = act.center
        AND art.ref_id = act.id
        AND art.ref_subid = act.subid
JOIN ACCOUNTS acc
        ON 
        (
                act.DEBIT_ACCOUNTCENTER = acc.center
                AND act.DEBIT_ACCOUNTID = acc.id 
        )
        OR 
        (
                act.CREDIT_ACCOUNTCENTER = acc.center
                AND act.CREDIT_ACCOUNTID = acc.id 
        )
WHERE
        art.ref_type = 'ACCOUNT_TRANS'
        AND art.trans_time >= par.FromDate
        AND art.trans_time < par.ToDate
        AND art.center = 1
        AND acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT','BANK_ACCOUNT_WEB','PAYTEL')
        AND act.AMOUNT <> 0