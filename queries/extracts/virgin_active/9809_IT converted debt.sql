SELECT
    p.CENTER || 'p' || p.ID pid,
    p.SEX,
    p.FULLNAME,
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PERSONTYPE,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt')                                                                                                                                   AR_TYPE,
    longToDate(art.TRANS_TIME)                                                                                                                                                 TRANS_TIME,
    art.AMOUNT,
    art.DUE_DATE,
    art.TEXT,
    longToDate(art.ENTRY_TIME) ENTRY_TIME,
    art.UNSETTLED_AMOUNT,
    art.COLLECTED_AMOUNT
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
WHERE
    p.COUNTRY = 'IT'
    AND art.EMPLOYEECENTER = 100
    AND art.EMPLOYEEID = 1
    AND art.REF_TYPE = 'ACCOUNT_TRANS'
    AND art.DUE_DATE IS NOT NULL
and p.center in ($$scope$$)