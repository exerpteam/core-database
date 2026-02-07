SELECT
   ar.center AS "CENTER",
    CASE
        WHEN ar.AR_TYPE = 1
        THEN 'CASH'
        WHEN ar.AR_TYPE = 4
        THEN 'PAYMENT'
        WHEN ar.AR_TYPE = 5
        THEN 'DEBT'
        WHEN ar.AR_TYPE = 6
        THEN 'INSTALLMENT'
    END AS "ACCOUNT_TYPE",
    ac.EXTERNAL_ID AS "GL_ACCOUNT",
    SUM(ar.BALANCE) AS "SUM"
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    ACCOUNTS ac
ON
    ac.center = ar.ASSET_ACCOUNTCENTER
AND ac.id = ar.ASSET_ACCOUNTID
WHERE
    ar.center IN (:scope)
GROUP BY
    ar.CENTER,
    ar.AR_TYPE,
    ac.EXTERNAL_ID