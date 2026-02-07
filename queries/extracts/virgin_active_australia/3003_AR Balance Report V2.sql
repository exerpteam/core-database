-- This is the version from 2026-02-05
--  
WITH
    params AS
    (   SELECT
            EXTRACT( EPOCH FROM date_trunc( 'day', (CURRENT_TIMESTAMP + INTERVAL '1 day') AT TIME
            ZONE 'Sydney/Australia' - INTERVAL '1 month' ) )::bigint AS lastmonthLong
    )
    ,
    v_per_trans AS
    (   SELECT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            p.fullname,
            p.status,
            case when p.sex = 'C' then 'COMPANY' else 'MEMBER' end as DebtorType,
            p.external_id,
            pa.state,
            art.trans_time,
            art.CENTER,
            art.unsettled_amount,
            ar.balance,
            ar.AR_TYPE
        FROM
            persons p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            p.center = ar.CUSTOMERCENTER
        AND p.id = ar.CUSTOMERID
        AND ar.balance < 0
        JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
        AND art.ID = ar.ID
        LEFT JOIN
            account_receivables pag
        ON
            pag.customercenter = p.center
        AND pag.customerid = p.id
        AND pag.AR_TYPE = 4
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = pag.CENTER
        AND pac.ID = pag.ID
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = pac.ACTIVE_AGR_CENTER
        AND pa.ID = pac.ACTIVE_AGR_ID
        AND pa.SUBID = pac.ACTIVE_AGR_SUBID
        WHERE
            --ar.AR_TYPE = 4
            ar.customercenter IN (:Scope)
        AND art.id > 1
        AND art.center IN (:Scope)
            --AND art.due_date < CURRENT_TIMESTAMP
        AND art.status IN ('OPEN',
                           'NEW')
        AND p.status NOT IN (4)
        AND art.due_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')
    )
SELECT
    t.CUSTOMERCENTER ||'p'|| t.CUSTOMERID AS PERSON_ID,
    t.DebtorType as DebtorType,
    t.fullname AS PERSON_NAME,
    t.CUSTOMERCENTER                      AS center,
    CASE 
        WHEN t.CUSTOMERCENTER = '100'  THEN 'HO'
        WHEN t.CUSTOMERCENTER = '2001' THEN 'NFF'
        WHEN t.CUSTOMERCENTER = '2003' THEN 'NPS'
        WHEN t.CUSTOMERCENTER = '2004' THEN 'NNW'
        WHEN t.CUSTOMERCENTER = '2005' THEN 'NMP'
        WHEN t.CUSTOMERCENTER = '2006' THEN 'VCS'
        WHEN t.CUSTOMERCENTER = '2008' THEN 'NBS'
        WHEN t.CUSTOMERCENTER = '2009' THEN 'NMS'
        WHEN t.CUSTOMERCENTER = '2010' THEN 'NSL'
        WHEN t.CUSTOMERCENTER = '2011' THEN 'NBJ'
        WHEN t.CUSTOMERCENTER = '2012' THEN 'NBW'
        ELSE 'UNKNOWN'
    END                                    AS center_name,
    t.external_id                         AS externalid,
    --t.CUSTOMERID                          AS ID,
    CASE t.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "Member Status",
    CASE t.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END AS "Payment Agreement Status",
    CASE AR_TYPE
        WHEN 1
        THEN 'Cash'
        WHEN 4
        THEN 'Payment'
        WHEN 5
        THEN 'Debt'
        WHEN 6
        THEN 'installment'
    END AS "Account Type",
    SUM(
    CASE
        WHEN t.trans_time > dateToLongC( TO_CHAR( date_trunc('day', (CURRENT_TIMESTAMP - INTERVAL
            '1 month')), 'YYYY-MM-DD HH24:MI' ), t.CENTER)
        THEN t.unsettled_amount
        ELSE 0
    END) AS "Debt 0-30 Days",
    SUM(
    CASE
        WHEN t.trans_time > dateToLongC( TO_CHAR( date_trunc('day', (CURRENT_TIMESTAMP - INTERVAL 
            '2 month')), 'YYYY-MM-DD HH24:MI' ), t.CENTER)
        AND t.trans_time < dateToLongC( TO_CHAR( date_trunc('day', (CURRENT_TIMESTAMP - INTERVAL 
            '1 month')), 'YYYY-MM-DD HH24:MI' ), t.CENTER)
        THEN t.unsettled_amount
        ELSE 0
    END) AS "Debt 30-60 Days",
    SUM(
    CASE
        WHEN t.trans_time < dateToLongC(
                TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP - INTERVAL '2 month'), 'YYYY-MM-DD HH24:MI'),
                t.CENTER
            )
         AND t.trans_time >= dateToLongC(
                TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP - INTERVAL '3 month'), 'YYYY-MM-DD HH24:MI'),
                t.CENTER
            )
        THEN t.unsettled_amount
        ELSE 0
    END
) AS "Debt 60-90 Days",

SUM(
    CASE
        WHEN t.trans_time < dateToLongC(
            TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP - INTERVAL '3 month'), 'YYYY-MM-DD HH24:MI'),
            t.CENTER
        )
        THEN t.unsettled_amount
        ELSE 0
    END
) AS "Debt 91+ Days",
    (SUM(t.unsettled_amount)) AS "Debt in Total"
FROM
    v_per_trans t
CROSS JOIN
    params
GROUP BY
    t.CUSTOMERCENTER,
    t.CUSTOMERID,
    t.fullname,
    t.DebtorType,
    t.external_id,
    t.STATUS,
    t.STATE,
    t.AR_TYPE
HAVING
    SUM(t.unsettled_amount) < 0
ORDER BY
    PERSON_ID