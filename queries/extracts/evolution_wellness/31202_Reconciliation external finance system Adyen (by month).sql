SELECT
    CENTER,
    EXTERNAL_ID,
    BOOK_MONTH,
    REPLACE('' || round(SUM(deb), 2), '.', ',') AS debit,
    REPLACE('' || round(SUM(cred), 2), '.', ',') AS credit,
    REPLACE('' || round(SUM(deb + cred), 2), '.', ',') AS total
FROM
(
    SELECT DISTINCT
        acc.CENTER AS center,
        acc.EXTERNAL_ID,
        sums.BOOK_MONTH,
        sums.debit,
        sums.credit,
        CASE
            WHEN acc.EXTERNAL_ID = sums.debit
                 AND acc.center = sums.center
            THEN sums.amount
            ELSE 0
        END AS deb,
        CASE
            WHEN acc.EXTERNAL_ID = sums.credit
                 AND acc.center = sums.center
            THEN -sums.amount
            ELSE 0
        END AS cred
    FROM
    (
        SELECT
            art.center AS center,
            art.DEBIT_ACCOUNT_EXTERNAL_ID AS debit,
            art.CREDIT_ACCOUNT_EXTERNAL_ID AS credit,
            date_trunc('month', art.BOOK_DATE)::date AS BOOK_MONTH,
            SUM(art.AMOUNT) AS amount
        FROM
            AGGREGATED_TRANSACTIONS art
        WHERE
            art.center IN (:scope)
            AND art.BOOK_DATE >= CAST(:FromDate AS date)
            AND art.BOOK_DATE < CAST(:ToDate AS date) + 1
        GROUP BY
            art.center,
            art.DEBIT_ACCOUNT_EXTERNAL_ID,
            art.CREDIT_ACCOUNT_EXTERNAL_ID,
            date_trunc('month', art.BOOK_DATE)::date
        ORDER BY
            art.center
    ) sums
    JOIN
    (
        SELECT DISTINCT
            CENTER,
            exteId AS external_id
        FROM
        (
            SELECT
                CENTER,
                DEBIT_ACCOUNT_EXTERNAL_ID AS exteId
            FROM
                AGGREGATED_TRANSACTIONS
            WHERE
                center IN (:scope)

            UNION

            SELECT
                CENTER,
                CREDIT_ACCOUNT_EXTERNAL_ID AS exteId
            FROM
                AGGREGATED_TRANSACTIONS
            WHERE
                center IN (:scope)
        ) t1
    ) acc
        ON acc.center = sums.center
       AND (
            sums.debit = acc.EXTERNAL_ID
            OR sums.credit = acc.EXTERNAL_ID
       )
    ORDER BY
        acc.center,
        acc.EXTERNAL_ID,
        sums.BOOK_MONTH
) t2
WHERE
    EXTERNAL_ID in ('258001-01','258001-25')

GROUP BY
    CENTER,
    EXTERNAL_ID,
    BOOK_MONTH
HAVING
    SUM(deb) <> 0
    OR SUM(cred) <> 0
ORDER BY
    CENTER,
    EXTERNAL_ID,
    BOOK_MONTH;
