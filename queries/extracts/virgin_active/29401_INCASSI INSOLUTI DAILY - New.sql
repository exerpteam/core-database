select
longtodate(prs.LAST_MODIFIED) as ultimaModifica, CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as personId, p1.FULLNAME as nominativo, 
DECODE(pr.STATE, 1, 'PS_NEW', 2, 'PS_SENT', 3, 'PS_DONE_MANUAL', 5, 'PS_DONE', 5, 'PS_REJECTED_BY_CLEARINGHOUSE', 12, 'PS_FAIL_NO_CREDITOR', 17,'PS_FAIL_REJ_DEB_REVOKED') "Stato",
 invl.TOTAL_AMOUNT as importoMovimento, PRS.open_amount as IMPORTOAPERTO, pr.REQ_DATE as scadenza, longtodate(prs.LAST_MODIFIED) as DataPagamento

FROM 

	PERSONS p1


JOIN 
ACCOUNT_RECEIVABLES ar
on
 ar.CUSTOMERCENTER = p1.CENTER
    AND ar.CUSTOMERID = p1.ID
AND ar.AR_TYPE = 4

LEFT 
	JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
  
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
  pr.CENTER = ar.CENTER
    AND pr.ID = ar.id  


LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID

LEFT JOIN AR_TRANS art
	ON art.PAYREQ_SPEC_SUBID = prs.SUBID
	and art.PAYREQ_SPEC_ID = prs.ID
	and art.PAYREQ_SPEC_CENTER = prs.CENTER
LEFT JOIN INVOICELINES invl
 on invl.ID = art.REF_ID
AND invl.CENTER = art.REF_CENTER
INNER JOIN CENTERS c
ON C.ID = PR.CENTER






WHERE 
pr.center IN (205,204,207,206,201,203,202,220,221,222,223,216,217,218,219,212,213,214,215,208,209,210,211,102,103,100,101,108,106,107,225,104,224,105)
--c.country = 'IT'

and pr.req_date <= ADD_MONTHS(LAST_DAY(SYSDATE),0)
and extract(day from pr.req_date) <= 2
and longtodate(prs.LAST_MODIFIED) between $$dataDaPagamento$$ and $$dataAPagamento$$
AND pr.REQ_DATE between $$dataDaScadenza$$ AND $$dataAScadenza$$

AND pr.STATE IS NOT NULL
AND ART.REF_TYPE = 'INVOICE'
AND PR.STATE IN (5,12,17)
--AND ar.CUSTOMERID = 7338
AND art.COLLECTED_AMOUNT <> 0
AND prs.OPEN_AMOUNT < prs.REQUESTED_AMOUNT


UNION ALL
select
DISTINCT longtodate(prs.LAST_MODIFIED) as ultimaModifica, CONCAT(CONCAT(cast(p1.CENTER as varchar(3)),'p'), cast(p1.ID as varchar(8))) as personId, p1.FULLNAME as nominativo,
DECODE(pr.STATE, 1, 'PS_NEW', 2, 'PS_SENT', 3, 'PS_DONE', 4, 'PS_DONE_MANUAL', 5, 'PS_REJECTED_BY_CLEARINGHOUSE', 12, 'PS_FAIL_NO_CREDITOR', 17,'PS_FAIL_REJ_DEB_REVOKED') "Stato", 
 art.AMOUNT as importoMovimento, PRS.open_amount as IMPORTOAPERTO, pr.REQ_DATE, longtodate(art.TRANS_TIME) as DataPagamento

FROM 

	PERSONS p1
INNER JOIN CENTERS c
ON c.ID = p1.CENTER

INNER JOIN 
ACCOUNT_RECEIVABLES ar
on
 ar.CUSTOMERCENTER = p1.CENTER
    AND ar.CUSTOMERID = p1.ID
AND ar.AR_TYPE = 4

INNER JOIN 
 PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
  
INNER JOIN
    PAYMENT_REQUESTS pr
ON
  pr.CENTER = ar.CENTER
    AND pr.ID = ar.id  


INNER JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID

INNER JOIN AR_TRANS art
	ON art.PAYREQ_SPEC_SUBID = prs.SUBID
	and art.PAYREQ_SPEC_ID = prs.ID
	and art.PAYREQ_SPEC_CENTER = prs.CENTER
WHERE
     art.TEXT LIKE 'Manual registered payment of request%'
AND Extract(DAY FROM pr.REQ_DATE) <= 2
AND Extract(DAY FROM LongToDate(art.ENTRY_TIME)) = 30
AND
Extract(MONTH FROM LongToDate(art.ENTRY_TIME)) = 9
AND
Extract(YEAR FROM LongToDate(art.ENTRY_TIME)) = 2017
AND
c.COUNTRY = 'IT'
and pr.req_date <= ADD_MONTHS(LAST_DAY(SYSDATE),0)
and extract(day from pr.req_date) <= 2
and longtodate(art.TRANS_TIME) between $$dataDaPagamento$$ and $$dataAPagamento$$
AND pr.REQ_DATE between $$dataDaScadenza$$ AND $$dataAScadenza$$


Order by personId




  
 