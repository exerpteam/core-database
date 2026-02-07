SELECT
    MAX(agr.LOG_DATE),
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID                                                                                                                                         pid,
    
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PERSONTYPE,
    nvl2(rel.CENTER,1,0)                                                                                                                                                               other_payer,
    TRUNC(exerpsysdate() - MAX(agr.LOG_DATE))                                                                                                                                                 days_missing ,
    pa.STATE,
    pa.CENTER,
    pa.ID,
    pa.SUBID
FROM
    PAYMENT_AGREEMENTS pa
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.ACTIVE_AGR_CENTER = pa.CENTER
    AND pac.ACTIVE_AGR_ID = pa.ID
    AND pac.ACTIVE_AGR_SUBID = pa.SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pac.CENTER
    AND ar.ID = pac.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
LEFT JOIN
    RELATIVES rel
ON
    rel.RTYPE = 12
    AND rel.STATUS = 1
    AND rel.CENTER = p.CENTER
    AND rel.ID = p.ID
JOIN
    AGREEMENT_CHANGE_LOG agr
ON
    agr.AGREEMENT_CENTER = pa.CENTER
    AND agr.AGREEMENT_ID = pa.id
    AND agr.AGREEMENT_SUBID = pa.SUBID
JOIN
    CENTERS c
ON
    c.ID = pa.CENTER
    AND c.COUNTRY = 'SE'
WHERE
    pa.state = 2
    --and pa.REF = '1304000000498001'
GROUP BY
    p.STATUS,
    p.PERSONTYPE,
    pa.STATE,
    pa.CENTER,
    pa.ID,
    pa.SUBID ,
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    rel.CENTER
HAVING
    TRUNC(exerpsysdate() - MAX(agr.LOG_DATE)) > 10