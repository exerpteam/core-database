SELECT
    *
    --    p.CENTER || 'p' || p.ID PersonID,
    --    ar.BALANCE              AS "Payment Account Balance",
    --    ar2.BALANCE             AS "Instalment Account Balance"
    --    --    , ar3.BALANCE             AS "Instalment Account Balance"
    --    ip.END_DATE
FROM
    (
        SELECT
            p.CENTER || 'p' || p.ID PersonID,
            ar.BALANCE              AS "Payment Account Balance",
            ar2.BALANCE             AS "Instalment Account Balance"
        FROM
            persons p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.center
            AND ar.CUSTOMERID = p.id
            AND ar.AR_TYPE = 4
        JOIN
            ACCOUNT_RECEIVABLES ar2
        ON
            ar2.CUSTOMERCENTER = p.center
            AND ar2.CUSTOMERID = p.id
            AND ar2.AR_TYPE = 6
        WHERE
            ar.BALANCE > 0
            AND ar2.BALANCE < 0
        UNION
        SELECT
            p.CENTER || 'p' || p.ID PersonID,
            ar.BALANCE              AS "Payment Account Balance",
            ar2.BALANCE             AS "Instalment Account Balance"
        FROM
            persons p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.center
            AND ar.CUSTOMERID = p.id
            AND ar.AR_TYPE = 4
        JOIN
            SATS.RELATIVES rel
        ON
            p.CENTER = rel.CENTER
            AND p.id = rel.ID
            AND rel.RTYPE = 12
        JOIN
            SATS.ACCOUNT_RECEIVABLES ar2
        ON
            ar2.CUSTOMERCENTER = rel.RELATIVECENTER
            AND ar2.CUSTOMERID = rel.RELATIVEID
            AND ar2.AR_TYPE = 6
        WHERE
            ar.BALANCE > 0
            AND ar2.BALANCE < 0 )