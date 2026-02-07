SELECT
    ar.center||'ar'||ar.id as "ID",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                    OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END AS "PERSON_ID",
    CASE AR_TYPE
        WHEN 1
        THEN 'Cash'
        WHEN 4
        THEN 'Payment'
        WHEN 5
        THEN 'Debt'
        WHEN 6
        THEN 'installment'
    END             AS "TYPE",
    balance as "BALANCE",
    ar.last_modified AS "ETS"
FROM
    account_receivables ar
JOIN
    persons p
ON
    p.center = ar.customercenter
AND p.id= ar.customerid
