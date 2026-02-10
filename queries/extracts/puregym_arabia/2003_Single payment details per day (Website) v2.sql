-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    V1."DATETIME",
    v1."account" ,
    v1."refund",
    v1."name",
    v1."Transaction Text" ,
    v1."Transaction ID" ,
    v1."personid" ,
    v1."External ID",
    v1."centerid",
    v1."payment",
    v1."ENTRYTIME",
    v1."Type"
FROM
    (
        WITH
            params AS
            (
                SELECT
                    /*+ materialize */
                    c.id,
                    CAST (dateToLongC(TO_CHAR(CAST(:fromDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)
                    AS BIGINT) AS FromDate,
                    CAST((dateToLongC(TO_CHAR(CAST(:toDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+
                    86400 * 1000)-1 AS BIGINT) AS ToDate
                FROM
                    centers c
                WHERE
                    c.id IN ($$Scope$$)
            )
        SELECT DISTINCT
            TO_CHAR(longtodateC(act.TRANS_TIME, act.center),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME",
            CASE
                WHEN acc.name = 'Cash register interim'
                THEN 'Bank account: WEB'
                ELSE acc.name
            END AS account,
            CASE
                WHEN (art.amount<0)
                THEN art.amount
                ELSE 0
            END                                                 AS REFUND ,
            p.fullname                                          AS Name,
            act.TEXT                                            AS "Transaction Text",
            CAST(convert_from(je.BIG_TEXT, 'UTF-8') AS VARCHAR) AS "Transaction ID",
            ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID             AS PersonId,
            p.external_id                                       AS "External ID",
            p.CENTER                                            AS CenterID,
            CASE
                WHEN (art.amount>0)
                THEN art.amount
                ELSE 0
            END                                                                      AS PAYMENT,
            TO_CHAR(longtodateC(act.ENTRY_TIME, act.center),'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME"
            ,
            CASE
                WHEN je.NAME LIKE '%Course Purchase Sage Pay'
                THEN REPLACE(je.NAME,'Purchase Sage Pay','')
                WHEN je.NAME LIKE '%Course Purchase'
                THEN REPLACE(je.NAME,'Purchase','')
                WHEN act.TEXT= 'API Sale Transaction'
                AND ar.AR_TYPE=4
                THEN 'Direct Debit Sale'
                WHEN act.TEXT= 'API Sale Transaction'
                AND ar.AR_TYPE=1
                AND je.NAME IN ('Day Pass Purchase Sage Pay',
                                'Day Pass Purchase')
                THEN 'Day Pass'
                WHEN act.TEXT= 'API Sale Transaction'
                AND ar.AR_TYPE=1
                AND je.NAME IN ('Pure Loser Purchase Sage Pay',
                                'Pure Loser Course Purchase Sage Pay',
                                'Pure Loser Purchase',
                                'Pure Loser Course Purchase')
                THEN 'Pure Loser Course'
                WHEN act.TEXT= 'API Sale Transaction'
                AND ar.AR_TYPE=1
                AND je.NAME IN ('Gift Voucher Purchase Sage Pay',
                                'Gift Voucher Purchase')
                THEN 'Gift Card Sale'
                WHEN je.NAME = 'Debt Payment'
                OR  acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT')
                THEN 'Debt Payment'
                WHEN (acc.name = 'Cash register interim'
                    AND act.ENTRY_TIME > pa.creation_time)
                THEN 'Direct Debit Sale'
                WHEN act.TEXT = 'API Register remaining money from payment request'
                AND ar.AR_type = 4
                AND je.name IN ('Payment')
                AND art.amount < 100
                THEN 'Day Pass'
                ELSE 'Unknown'
            END AS "Type" ,
            rank() over (partition BY CAST(convert_from(je.BIG_TEXT, 'UTF-8') AS VARCHAR),
            pa2.creation_time ORDER BY pa2.creation_time DESC ) AS RNK
        FROM
            ACCOUNTS acc
        JOIN
            ACCOUNT_TRANS act
        ON
            ( act.DEBIT_ACCOUNTCENTER = acc.center
            AND act.DEBIT_ACCOUNTID = acc.id )
        OR  ( act.CREDIT_ACCOUNTCENTER = acc.center
            AND act.CREDIT_ACCOUNTID = acc.id )
        JOIN
            AR_TRANS art
        ON
            art.REF_TYPE = 'ACCOUNT_TRANS'
        AND art.REF_CENTER = act.center
        AND art.REF_ID = act.id
        AND art.REF_SUBID = act.subid
        JOIN
            ACCOUNT_RECEIVABLES AR
        ON
            AR.CENTER = art.CENTER
        AND AR.ID = ART.ID
        JOIN
            PERSONS P
        ON
            P.CENTER = AR.CUSTOMERCENTER
        AND P.ID = AR.CUSTOMERID
        JOIN
            params
        ON
            params.id = acc.center
        LEFT JOIN
            JOURNALENTRIES je
        ON
            p.ID = je.PERSON_ID
        AND p.CENTER = je.PERSON_CENTER
        AND ( je.NAME IN ('Debts Payment Sage Pay',
                          'Day Pass Purchase Sage Pay',
                          'Pure Loser Purchase Sage Pay',
                          --'Grit Course Purchase Sage Pay',
                          'Join Payment Sage Pay',
                          'Debt Payment Sage Pay',
                          'Day-pass Payment Sage Pay',
                          'Pureloser Payment Sage Pay',
                          'Course Payment Sage Pay',
                          'Gift Voucher Purchase Sage Pay',
                          'Debt Payment',
                          'Day Pass Purchase',
                          'Pure Loser Purchase',
                          'Join Payment',
                          'Day-pass Payment',
                          'Pureloser Payment',
                          'Course Payment',
                          'Gift Voucher Purchase',
                          'Payment'
                          --'Pure Loser Course Purchase Sage Pay',
                          --'Pure LifeStyle Course Purchase Sage Pay',
                          --'Pure LifeStyle with Protein World Course Purchase Sage Pay',
                          --'Zuu Fitness Course Purchase Sage Pay'
                          )
            OR  je.NAME LIKE '%Course Purchase%' )
        AND je.CREATION_TIME BETWEEN act.ENTRY_TIME-300000 AND act.ENTRY_TIME+300000
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            ar.center = pa.CENTER
        AND ar.id = pa.ID
        AND pa.clearinghouse in (201,401,1001)
        AND pa.active = 'true'
        LEFT JOIN
            PAYMENT_AGREEMENTS pa2
        ON
            ar.center = pa2.CENTER
        AND ar.id = pa2.ID
        AND pa2.clearinghouse = 1
        WHERE
            act.AMOUNT <> 0
        AND acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT',
                             'BANK_ACCOUNT_WEB',
                             'PAYTEL',
                             'BANK_ACCOUNT_MADA',
                             'CASHREGISTER_INTERIM')
        AND act.TRANS_TIME >= params.FromDate
        AND act.TRANS_TIME < params.ToDate
        AND 1=
            CASE
                WHEN je.CREATION_TIME IS NOT NULL
                THEN
                    CASE
                        WHEN
                            CASE
                                WHEN je.CREATION_TIME> act.ENTRY_TIME
                                THEN (je.CREATION_TIME - act.ENTRY_TIME)
                                ELSE (act.ENTRY_TIME - je.CREATION_TIME)
                            END=
                            (
                                SELECT
                                    MIN(
                                        CASE
                                            WHEN ClosestJE.CREATION_TIME> act.ENTRY_TIME
                                            THEN (ClosestJE.CREATION_TIME - act.ENTRY_TIME)
                                            ELSE (act.ENTRY_TIME - ClosestJE.CREATION_TIME)
                                        END)
                                FROM
                                    JOURNALENTRIES ClosestJE
                                WHERE
                                    ( ClosestJE.NAME IN ('Debts Payment Sage Pay',
                                                         'Day Pass Purchase Sage Pay',
                                                         'Pure Loser Purchase Sage Pay',
                                                         --'Grit Course Purchase Sage Pay',
                                                         'Join Payment Sage Pay',
                                                         'Debt Payment Sage Pay',
                                                         'Day-pass Payment Sage Pay',
                                                         'Pureloser Payment Sage Pay',
                                                         'Course Payment Sage Pay',
                                                         'Gift Voucher Purchase Sage Pay',
                                                         'Debt Payment',
                                                         'Day Pass Purchase',
                                                         'Pure Loser Purchase',
                                                         'Join Payment',
                                                         'Day-pass Payment',
                                                         'Pureloser Payment',
                                                         'Course Payment',
                                                         'Gift Voucher Purchase',
                                                         'Payment'
                                                         --'Pure Loser Course Purchase Sage Pay',
                                                         --'Pure LifeStyle Course Purchase Sage Pay
                                                         -- ',
                                                         --'Pure LifeStyle with Protein World
                                                         -- Course Purchase Sage Pay',
                                                         --'Zuu Fitness Course Purchase Sage Pay'
                                                         )
                                    OR  ClosestJE.NAME LIKE '%Course Purchase%' )
                                AND p.ID = ClosestJE.PERSON_ID
                                AND p.CENTER = ClosestJE.PERSON_CENTER )
                        THEN 1
                        ELSE 0
                    END
                WHEN je.CREATION_TIME IS NULL
                THEN 1
            END
        ORDER BY
            "DATETIME")v1
WHERE
    v1.RNK = 1