-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    account           AS "Account",
    center            AS "Centre",
    c.shortname            AS "Centre Name",
    SUM(debitamount)  AS "Debit",
    SUM(creditamount) AS "Credit",
    "TYPE"
FROM
    (
        SELECT
            agt.center                     AS center,
            agt.credit_account_external_id AS account,
            0                              AS debitamount,
            agt.amount                     AS creditamount ,
            CASE
                WHEN agt.credit_vat_account_external_id IS NOT NULL
                THEN 'SALE'
                WHEN (agt.credit_account_external_id LIKE '222%'
                    OR  agt.debit_account_external_id LIKE '222%')
                THEN 'DEFR'
                ELSE 'OTHER'
            END AS "TYPE"
        FROM
            aggregated_transactions agt
        WHERE
            agt.credit_account_external_id != 'NO_FUSION'
        AND agt.debit_account_external_id != 'NO_FUSION'
        AND agt.credit_account_external_id != agt.debit_account_external_id
        AND agt.book_date BETWEEN ($$fromdate$$) AND (
                $$todate$$)
        AND agt.center IN ($$scope$$)
        UNION ALL
        SELECT
            agt.center                    AS center,
            agt.debit_account_external_id AS account,
            agt.amount                    AS debitamount,
            0                             AS creditamount,
            CASE
                WHEN agt.debit_vat_account_external_id IS NOT NULL
                THEN 'SALE'
                WHEN (agt.credit_account_external_id LIKE '222%'
                    OR  agt.debit_account_external_id LIKE '222%')
                THEN 'DEFR'
                ELSE 'OTHER'
            END AS "TYPE"
        FROM
            aggregated_transactions agt
        WHERE
            agt.credit_account_external_id != 'NO_FUSION'
        AND agt.debit_account_external_id != 'NO_FUSION'
        AND agt.credit_account_external_id != agt.debit_account_external_id
        AND agt.book_date BETWEEN ($$fromdate$$) AND (
                $$todate$$)
        AND agt.center IN ($$scope$$)
        UNION ALL
        SELECT
            agt.center                         AS center,
            agt.credit_vat_account_external_id AS account,
            0                                  AS debitamount,
            agt.vat_amount                     AS creditamount ,
            'VAT'                              AS "TYPE"
        FROM
            aggregated_transactions agt
        WHERE
            agt.credit_account_external_id != 'NO_FUSION'
        AND agt.debit_account_external_id != 'NO_FUSION'
        AND agt.credit_account_external_id != agt.debit_account_external_id
        AND agt.credit_vat_account_external_id IS NOT NULL
        AND agt.book_date BETWEEN ($$fromdate$$) AND (
                $$todate$$)
        AND agt.center IN ($$scope$$)
        UNION ALL
        SELECT
            agt.center                        AS center,
            agt.debit_vat_account_external_id AS account,
            agt.vat_amount                    AS debitamount,
            0                                 AS creditamount,
            'VAT'                             AS "TYPE"
        FROM
            aggregated_transactions agt
        WHERE
            agt.credit_account_external_id != 'NO_FUSION'
        AND agt.debit_account_external_id != 'NO_FUSION'
        AND agt.credit_account_external_id != agt.debit_account_external_id
        AND agt.debit_vat_account_external_id IS NOT NULL
        AND agt.book_date BETWEEN ($$fromdate$$) AND (
                $$todate$$)
        AND agt.center IN ($$scope$$) ) AS t1
        JOIN CENTERS c on c.id = center
GROUP BY
    center,c.shortname,
    account,
    "TYPE"
ORDER BY
    "Centre",
    account,
    "TYPE" DESC