SELECT
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    PERSONS.firstname,
    PERSONS.lastname,
    PERSONS.STATUS,
    ar.BALANCE,
    NVL(SUM(art.UNSETTLED_AMOUNT), 0) AS "Open, Not Due Balance"
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    persons
ON
    ar.customercenter = PERSONS.center
AND ar.customerid = PERSONS.id
LEFT JOIN
    VA.AR_TRANS art
ON
    ar.center = art.CENTER
AND ar.ID = art.ID
AND (
        art.DUE_DATE IS NULL
    OR  art.DUE_DATE > SYSDATE)
AND art.UNSETTLED_AMOUNT !=0
WHERE
    ar.CENTER IN (:scope)
AND ar.AR_TYPE = :Kontotype
AND ar.BALANCE > :MoreThan
AND ar.BALANCE < :LessThan
GROUP BY
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    PERSONS.firstname,
    PERSONS.lastname,
    PERSONS.STATUS,
    ar.BALANCE