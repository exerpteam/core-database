SELECT
    p.center||'p'||p.id                                              AS "PERSON_ID",
    cp.EXTERNAL_ID                                                   AS "EXTERNAL_ID",
    art.AMOUNT                                                       AS "AMOUNT",
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt',6,'installment') AS "ACCOUNT_TYPE",
    TO_CHAR(longtodate(art.ENTRY_TIME),'dd.MM.YYYY')         AS "ENTRY_TIME",
    art.TEXT                                                         AS "TEXT"
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
    AND ar.id = art.id
JOIN
    PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
WHERE
    art.ENTRY_TIME BETWEEN  $$from_date$$ AND $$to_date$$ 
    AND
 ar.center IN ($$scope$$)