-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3148
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(to_char($$fromdate$$, 'YYYY-MM-dd HH24:MI'),  'Europe/London')   AS FromDate,
            datetolongTZ(to_char($$todate$$+1, 'YYYY-MM-dd HH24:MI'),  'Europe/London')   AS ToDate
        FROM
            dual
    )
SELECT
    TO_CHAR(longtodateTZ(act.TRANS_TIME, 'Europe/London'),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME",
    acc.name                                                                       AS account,
    CASE
        WHEN (art.amount<0)
        THEN art.amount
        ELSE 0
    END                                     AS REFUND ,
    p.fullname                              AS Name,
    act.TEXT                                AS "Transaction Text",
    UTL_RAW.CAST_TO_VARCHAR2(je.BIG_TEXT)   AS "Transaction ID",
    ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS PersonId,
	p.CENTER								AS CenterID,
    CASE
        WHEN (art.amount>0)
        THEN art.amount
        ELSE 0
    END                                                                            AS PAYMENT,
    TO_CHAR(longtodateTZ(act.ENTRY_TIME, 'Europe/London'),'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME",
    CASE
        WHEN je.NAME = 'Pure LifeStyle Course Purchase Sage Pay'
        THEN 'Pure LifeStyle Course'      
        WHEN act.TEXT= 'API Sale Transaction'
            AND ar.AR_TYPE=4
        THEN 'Direct Debit Sale'
        WHEN act.TEXT= 'API Sale Transaction'
            AND ar.AR_TYPE=1
            AND je.NAME = 'Day Pass Purchase Sage Pay'
        THEN 'Day Pass'
        WHEN act.TEXT= 'API Sale Transaction'
            AND ar.AR_TYPE=1
            AND je.NAME IN ('Pure Loser Purchase Sage Pay', 'Pure Loser Course Purchase Sage Pay')
        THEN 'Pure Loser Course'		
        WHEN act.TEXT= 'API Sale Transaction'
            AND ar.AR_TYPE=1
            AND je.NAME = 'Gift Voucher Purchase Sage Pay'
        THEN 'Gift Card Sale'
        WHEN acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT')
        THEN 'Debt Payment'
        ELSE 'Unknown'
    END AS "Type"
FROM
    ACCOUNTS acc
CROSS JOIN
   params 
JOIN
    ACCOUNT_TRANS act
ON
    (
        act.DEBIT_ACCOUNTCENTER = acc.center
        AND act.DEBIT_ACCOUNTID = acc.id )
    OR (
        act.CREDIT_ACCOUNTCENTER = acc.center
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
LEFT JOIN
    JOURNALENTRIES je
ON
    p.ID = je.PERSON_ID
    AND p.CENTER = je.PERSON_CENTER
    AND je.NAME IN ('Debts Payment Sage Pay',
                    'Day Pass Purchase Sage Pay',
                    'Pure Loser Purchase Sage Pay',
                    'Grit Course Purchase Sage Pay',
                    'Join Payment Sage Pay',
                    'Debt Payment Sage Pay',
                    'Day-pass Payment Sage Pay',
                    'Pureloser Payment Sage Pay',
                    'Course Payment Sage Pay',
                    'Gift Voucher Purchase Sage Pay',
		            'Pure Loser Course Purchase Sage Pay',
		    	    'Pure LifeStyle Course Purchase Sage Pay')
    AND je.CREATION_TIME BETWEEN act.ENTRY_TIME-300000 AND act.ENTRY_TIME+300000
WHERE
    act.AMOUNT <> 0
    AND acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT',
                         'BANK_ACCOUNT_WEB',
                         'PAYTEL')
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
                            ClosestJE.NAME IN ('Debts Payment Sage Pay',
                                               'Day Pass Purchase Sage Pay',
                                               'Pure Loser Purchase Sage Pay',
                                               'Grit Course Purchase Sage Pay',
                                               'Join Payment Sage Pay',
                                               'Debt Payment Sage Pay',
                                               'Day-pass Payment Sage Pay',
                                               'Pureloser Payment Sage Pay',
                                               'Course Payment Sage Pay',
                                               'Gift Voucher Purchase Sage Pay',
			                       			   'Pure Loser Course Purchase Sage Pay',
			                       			   'Pure LifeStyle Course Purchase Sage Pay')
                            AND p.ID = ClosestJE.PERSON_ID
                            AND p.CENTER = ClosestJE.PERSON_CENTER )
                THEN 1
                ELSE 0
            END
        WHEN je.CREATION_TIME IS NULL
        THEN 1
    END
and p.center in ($$scope$$)
ORDER BY
    "DATETIME"