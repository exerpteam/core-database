SELECT
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
    DECODE(p.SEX,'C','Company','Private') CUSTOMER_TYPE,
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') account_type,
    exerpro.longToDate(art.TRANS_TIME) TRANS_TIME,
    art.AMOUNT,
    art.UNSETTLED_AMOUNT,
    art.TEXT,
	art.REF_TYPE
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.id  = ar.CUSTOMERID
WHERE
    art.TRANS_TIME < exerpro.dateToLong(TO_CHAR(TRUNC(exerpsysdate()-1),'YYYY-MM-DD') || ' 00:00')
    AND art.AMOUNT > 0
    AND art.UNSETTLED_AMOUNT != 0
    AND art.CENTER IN ($$scope$$)
ORDER BY
    ar.CUSTOMERCENTER ,
    ar.CUSTOMERID,ar.AR_TYPE