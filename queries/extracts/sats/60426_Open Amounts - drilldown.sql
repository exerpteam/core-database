SELECT
  cp.center || 'p' || cp.id AS "PERSON_ID",
    CASE
        WHEN ar.AR_TYPE = 1
        THEN 'CASH'
        WHEN ar.AR_TYPE = 4
        THEN 'PAYMENT'
        WHEN ar.AR_TYPE = 5
        THEN 'DEBT'
        WHEN ar.AR_TYPE = 6
        THEN 'INSTALLMENT'
    END            AS "ACCOUNT_TYPE",
    ac.EXTERNAL_ID AS "GL_ACCOUNT",
    SUM(art.AMOUNT) AS "OPEN_AMOUNT"
FROM
    AR_TRANS art
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
AND ar.id = art.id
LEFT JOIN
    ACCOUNTS ac
ON
    ac.center = ar.ASSET_ACCOUNTCENTER
AND ac.id = ar.ASSET_ACCOUNTID
LEFT JOIN
    PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
AND p.id = ar.CUSTOMERID
LEFT JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
WHERE
    art.STATUS IN ('OPEN',
                   'NEW')
AND art.center IN (:scope)
GROUP BY
    cp.center || 'p' || cp.id ,
    ar.AR_TYPE,
    ac.EXTERNAL_ID 
