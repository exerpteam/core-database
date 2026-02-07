SELECT
    s.*,
    OpenAmountOverdueDebt - OldOverdueDebt AS Diff
FROM
    (
        SELECT
            p.center,
            p.id,
            MAX(p.sex)               AS sex,
            MAX(NVL(dar.balance, 0)) AS ExternalDebtBalance,
            least(SUM(
                CASE
                    WHEN
                        (
                            art.AMOUNT >= 0
                            OR
                            (
                                art.AMOUNT < 0
                                AND art.due_date IS NOT NULL
                                AND art.due_date < exerpsysdate()
                            )
                        )
                    THEN art.amount
                    ELSE 0
                END ),0) AS OldOverdueDebt,
            SUM(
                CASE
                    WHEN art.UNSETTLED_AMOUNT < 0
                        AND art.due_date IS NOT NULL
                        AND art.due_date < exerpsysdate()
                        AND art.STATUS IN ('NEW', 'OPEN')
                    THEN art.UNSETTLED_AMOUNT
                    ELSE 0
                END ) AS OpenAmountOverdueDebt
        FROM
            ACCOUNT_RECEIVABLES ar
        JOIN PERSONS p
        ON
            p.center = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        JOIN AR_TRANS art
        ON
            art.center = ar.center
            AND art.id = ar.id
        LEFT JOIN ACCOUNT_RECEIVABLES dar
        ON
            dar.CUSTOMERCENTER = p.center
            AND dar.CUSTOMERID = p.id
            AND dar.AR_TYPE = 5
            AND dar.BALANCE < 0
        WHERE
            ar.center in (:scope)
            AND ar.AR_TYPE = 4
            AND ar.BALANCE < 0
        GROUP BY
            p.center,
            p.id
    )
    s
WHERE
    s.OpenAmountOverdueDebt != s.OldOverdueDebt