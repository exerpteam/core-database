-- This is the version from 2026-02-05
--  
SELECT
    r.relativecenter || 'p' || r.relativeid      AS MemberId,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID    AS PaidBy,
    ABS(SUM(art.AMOUNT))                         AS "Amount in debt",
    NVL2(ccc.cashcollectionservice, 'Yes', 'No') AS "Sent to debt collection agency",
ccc.CURRENTSTEP as currentstep,
ccc.CASHCOLLECTIONSERVICE as agency,
ccc.CURRENTSTEP_DATE as datecurrentstep,
DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS

FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    persons p
ON
    p.center = ar.customercenter
    and p.id = ar.customerid    	
JOIN
    relatives r
ON
    r.center = ar.customercenter
    AND r.id = ar.customerid
    AND r.rtype = 12
    AND r.status < 3
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = ar.customercenter
    AND ccc.PERSONID = ar.customerid
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1
WHERE
    ar.AR_TYPE = 4
    AND r.relativecenter IN ($$Scope$$)
    AND art.status IN ('OPEN','NEW')
	AND p.sex != 'C'
GROUP BY
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID,
    r.relativecenter || 'p' || r.relativeid ,
    ccc.cashcollectionservice,
    ccc.CURRENTSTEP,
ccc.CASHCOLLECTIONSERVICE,
ccc.CURRENTSTEP_DATE,
p.STATUS
HAVING
    ABS(SUM(art.AMOUNT)) >= $$Amount$$
