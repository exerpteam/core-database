-- This is the version from 2026-02-05
--  
SELECT
    pid,
    CREDITOR,
    PAYMENTBALANCE,
    EXTERNALDEBTBALANCE,
    OLDOVERDUEDEBT,
    /*OLDOVERDUEDEBTMINUSUNCOLCRED,*/
    OPENAMOUNTOVERDUEDEBT,
    LATESTDUEDATE,
    LATESTTRANS,
    LATESTUNSETTLEDTRANSACTION,
    NONCOLLECTEDCREDITED,
    CC_AMOUNT,
    DIFF,
    UNEXPECTEDDIFF/*,
    PAYMENTBALANCE - OPENAMOUNTOVERDUEDEBT*/
FROM
    (
        SELECT
            s.*,
            OpenAmountOverdueDebt - OldOverdueDebt                        AS Diff,
            OpenAmountOverdueDebt - OldOverdueDebt + NonCollectedCredited AS UnexpectedDiff,
            s.PaymentBalance -                                               OpenAmountOverdueDebt
        FROM
            (
                SELECT
                    p.center || 'p' || p.id pid,
                    p.status,
                    ar.center                AS arcenter,
                    ar.id                    AS arid,
                    MAX(pag.CREDITOR_ID)     AS CREDITOR,
                    MAX(p.sex)               AS sex,
                    ar.balance               AS PaymentBalance,
                    MAX(NVL(dar.balance, 0)) AS ExternalDebtBalance,
                    least(SUM(
                        CASE
                            WHEN (art.AMOUNT >= 0
                                    OR (art.AMOUNT < 0
                                        AND art.due_date IS NOT NULL
                                        AND art.due_date < exerpsysdate()))
                                --and art.INSTALLMENT_PLAN_ID is null
                            THEN art.amount
                            ELSE 0
                        END ),0) AS OldOverdueDebt,
                    least(SUM(
                        CASE
                            WHEN ((art.AMOUNT >= 0
                                        AND (art.collected > 0
                                            OR art.ENTRY_TIME <= ar.COLLECTED_UNTIL))
                                    OR (art.AMOUNT < 0
                                        AND art.due_date IS NOT NULL
                                        AND art.due_date < exerpsysdate()))
                                --and art.INSTALLMENT_PLAN_ID is null
                            THEN art.amount
                            ELSE 0
                        END ),0) AS OldOverdueDebtMinusUncolCred,
                    SUM(
                        CASE
                            WHEN art.UNSETTLED_AMOUNT < 0
                                AND art.due_date IS NOT NULL
                                AND art.due_date < exerpsysdate()
                                AND art.STATUS IN ('NEW',
                                                   'OPEN')
                            THEN art.UNSETTLED_AMOUNT
                            ELSE 0
                        END )                               AS OpenAmountOverdueDebt ,
                    MAX(art.DUE_DATE)                       AS LatestDueDate ,
                    MAX(exerpro.longtodate(art.ENTRY_TIME)) AS LatestTrans ,
                    MAX(
                        CASE
                            WHEN art.UNSETTLED_AMOUNT < 0
                                AND art.due_date IS NOT NULL
                                AND art.due_date < exerpsysdate()
                                AND art.STATUS IN ('NEW',
                                                   'OPEN')
                            THEN art.DUE_DATE
                            ELSE to_date('1900-01-01','YYYY-MM-DD')
                        END)                            AS LatestUnsettledTransaction ,
                    MAX(NVL(art.INSTALLMENT_PLAN_ID,0)) AS InstallmentPlan ,
                    SUM(
                        CASE
                            WHEN (art.AMOUNT >= 0
                                    AND art.COLLECTED = 0
                                    AND art.ENTRY_TIME > ar.COLLECTED_UNTIL)
                                --and art.INSTALLMENT_PLAN_ID is null
                            THEN art.amount
                            ELSE 0
                        END )  AS NonCollectedCredited ,
                    ccc.amount AS CC_AMOUNT
                FROM
                    ACCOUNT_RECEIVABLES ar
                JOIN
                    PERSONS p
                ON
                    p.center = ar.CUSTOMERCENTER
                    AND p.id = ar.CUSTOMERID
                JOIN
                    AR_TRANS art
                ON
                    art.center = ar.center
                    AND art.id = ar.id
                JOIN
                    PAYMENT_ACCOUNTS pa
                ON
                    pa.CENTER = ar.center
                    AND pa.id = ar.id
                LEFT JOIN
                    PAYMENT_AGREEMENTS pag
                ON
                    pag.center = pa.ACTIVE_AGR_CENTER
                    AND pag.id = pa.ACTIVE_AGR_ID
                    AND pag.subid = pa.ACTIVE_AGR_SUBID
                LEFT JOIN
                    ACCOUNT_RECEIVABLES dar
                ON
                    dar.CUSTOMERCENTER = p.center
                    AND dar.CUSTOMERID = p.id
                    AND dar.AR_TYPE = 5
                    AND dar.BALANCE < 0
                LEFT JOIN
                    CASHCOLLECTIONCASES ccc
                ON
                    ccc.PERSONCENTER = p.center
                    AND ccc.PERSONID = p.id
                    AND ccc.CLOSED = 0
                    AND ccc.MISSINGPAYMENT = 1
                WHERE
                    ar.center IN
                    ($$scope$$)
                    AND ar.AR_TYPE = 4
                    AND ar.BALANCE < 0
                GROUP BY
                    p.center,
                    p.id,
                    p.status,
                    ccc.amount,
                    ar.center,
                    ar.id,
                    ar.balance ) s
        WHERE 
            s.sex = 'C'
    )