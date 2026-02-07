SELECT s.clubId, s.personId, sum(s.importoRichiesto) as importoRichiesto,
sum(s.importoPagato) as importoPagato from(
select
c.EXTERNAL_ID as clubId,
CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as personId, 
pr.REQ_AMOUNT as importoRichiesto,
0 as importoPagato
 
 
 
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

LEFT JOIN ACCOUNT_TRANS act
ON
act.CENTER = invl.ACCOUNT_TRANS_CENTER
AND
act.ID = invl.ACCOUNT_TRANS_ID
AND
act.SUBID = invl.ACCOUNT_TRANS_SUBID

INNER JOIN ACCOUNTS debac
ON debac.center = act.DEBIT_ACCOUNTCENTER
AND debac.ID = act.DEBIT_ACCOUNTID

INNER JOIN ACCOUNTS credac
ON credac.center = act.CREDIT_ACCOUNTCENTER

AND credac.ID = act.CREDIT_ACCOUNTID

LEFT JOIN CENTERS c
ON c.ID = pr.CENTER



WHERE 
--PR.center = 102
c.COUNTRY = 'IT'
 and extract(month from pr.req_date) = EXTRACT(month FROM  ADD_MONTHS(SYSDATE,-1))
and extract(year from  pr.req_date) = extract(YEAR FROM ADD_MONTHS(SYSDATE,-1))
and extract(day from pr.req_date) <= 2
AND pr.STATE IS NOT NULL
AND pr.STATE != 12
AND ART.REF_TYPE = 'INVOICE'
--AND ar.CUSTOMERID = 7338
AND art.COLLECTED_AMOUNT <> 0
--AND pr.CLEARINGHOUSE_ID = 803
AND pr.CLEARINGHOUSE_ID IN(803,
                               2801,
                               2802,
                               2803,
                               2804)
AND pr.STATE != 12
--AND p1.ID IN(17756, 17754)
--AND p1.CENTER = 101
GROUP BY
c.EXTERNAL_ID,
CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))),
pr.REQ_AMOUNT,
pr.CENTER,
pr.ID,
pr.SUBID

UNION ALL

SELECT C.EXTERNAL_ID as ClubId, CONCAT(CONCAT(cast(a.CUSTOMERCENTER as char(3)),'p'), cast(a.CUSTOMERID as varchar(8))) as personId, SUM(0) as importoRichiesto,  SUM(ar.AMOUNT) AS importoPagato FROM AGGREGATED_TRANSACTIONS agt
INNER JOIN CENTERS c

ON c.ID = agt.CENTER
INNER JOIN ACCOUNT_TRANS act ON 
agt.CENTER = act.AGGREGATED_TRANSACTION_CENTER
and 
agT.id = act.AGGREGATED_TRANSACTION_ID
INNER JOIN
AR_TRANS ar
ON
act.ID = ar.REF_ID
AND
act.SUBID = ar.REF_SUBID
AND
act.CENTER = ar.REF_CENTER
INNER JOIN
ACCOUNT_RECEIVABLES
 a
ON ar.center = a.center
AND
ar.id = a.id
WHERE
REGEXP_LIKE (agt.TEXT, ' Debt to [0-9]{3},[0-9]{1,}$')
--SELECT * FROM ACCOUNT_TRANS WHERE AGGREGATED_TRANSACTION_ID = 8951 
--AND AGGREGATED_TRANSACTION_CENTER = 101
 and extract(month from agt.BOOK_DATE) = EXTRACT(month FROM  ADD_MONTHS(SYSDATE,-1))
and extract(year from  agt.BOOK_DATE) = extract(YEAR FROM ADD_MONTHS(SYSDATE,-1))

AND c.COUNTRY = 'IT'
AND agt.INFO != '0'
AND C.ID != 100
GROUP BY C.EXTERNAL_ID,CONCAT(CONCAT(cast(a.CUSTOMERCENTER as char(3)),'p'), cast(a.CUSTOMERID as varchar(8))) 




) s
GROUP by s.clubId, s.personId
ORDER BY s.clubId, s.personId



