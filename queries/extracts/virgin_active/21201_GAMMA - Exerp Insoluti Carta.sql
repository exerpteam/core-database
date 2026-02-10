-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT ins.SHORTNAME,
ins.PERSONID,
ins.FULLNAME,
ins.TEXT,
ins.REQUESTED_AMOUNT,
ins.REQ_DATE
 from (
SELECT 
NVL(r2.shortname, r1.shortname) as shortname,
NVL(r2.personid, r1.personId) as personId,
NVL(r2.FULLNAME, r1.FULLNAME) as FULLNAME,
NVL(r2.TEXT, r1.TEXT) as TEXT,
NVL(r2.REQUESTED_AMOUNT, r1.REQUESTED_AMOUNT) as REQUESTED_AMOUNT,
NVL(r2.xfr_AMOUNT, r1.XFR_AMOUNT) as XFR_AMOUNT,
NVL(r2.REQ_DATE, r1.REQ_DATE) as REQ_DATE


 FROM


(SELECT 


c.shortname,
CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId,
p.FULLNAME,
MAX(INV.TEXT) AS TEXT,
prs.REQUESTED_AMOUNT,
pr.XFR_AMOUNT,
pr.req_date



FROM

	PERSONS p


inner join
ACCOUNT_RECEIVABLES ar
on
 ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
AND ar.AR_TYPE = 4



  
INNER JOIN
    PAYMENT_REQUESTS pr
ON
  pr.CENTER = ar.CENTER
    AND pr.ID = ar.id  
  



INNER JOIN CLEARING_OUT co
ON co.ID = pr.REQ_DELIVERY
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
    and art.REF_TYPE = 'INVOICE'
	and art.center = prs.CENTER
LEFT OUTER join
INVOICES inv

 on inv.ID = art.REF_ID
AND inv.CENTER = art.REF_CENTER
AND art.REF_TYPE = 'INVOICE'





INNER JOIN CENTERS C
on c.ID = prs.CENTER
	WHERE
EXTRACT(MONTH FROM pr.REQ_DATE) = 12
AND EXTRACT(YEAR FROM pr.REQ_DATE) = 2016
AND EXTRACT(MONTH FROM co.SENT_DATE) = 11
AND EXTRACT(YEAR FROM co.SENT_DATE) = 2016

and co.CLEARINGHOUSE = 803
and pr.XFR_AMOUNT IS NULL
--and prs.CENTER = 223
--and prs.ID = 17478
--and prs.SUBID = 1

group by 
p.CENTER,
P.ID,
c.shortname,
p.FULLNAME,
prs.REQUESTED_AMOUNT,
pr.XFR_AMOUNT,
pr.req_date,
pr.REJECTED_REASON_CODE
--prs.center,
--prs.id,
--prs.subid
order by 
c.shortname,
p.FULLNAME) r1
LEFT OUTER JOIN (
SELECT 


c.shortname,
CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId,
p.FULLNAME,
MAX(INV.TEXT) AS TEXT,
prs.REQUESTED_AMOUNT,
pr.XFR_AMOUNT,
pr.req_date



FROM

	PERSONS p


inner join
ACCOUNT_RECEIVABLES ar
on
 ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
AND ar.AR_TYPE = 4



  
INNER JOIN
    PAYMENT_REQUESTS pr
ON
  pr.CENTER = ar.CENTER
    AND pr.ID = ar.id  
  



INNER JOIN CLEARING_OUT co
ON co.ID = pr.REQ_DELIVERY
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
    and art.REF_TYPE = 'INVOICE'
	and art.center = prs.CENTER
LEFT OUTER join
INVOICES inv

 on inv.ID = art.REF_ID
AND inv.CENTER = art.REF_CENTER
AND art.REF_TYPE = 'INVOICE'





INNER JOIN CENTERS C
on c.ID = prs.CENTER
	WHERE
EXTRACT(MONTH FROM pr.REQ_DATE) = Extract(MONTH FROM(ADD_MONTHS(SYSDATE,-1))) 
AND EXTRACT(YEAR FROM pr.REQ_DATE) = Extract(YEAR FROM(ADD_MONTHS(SYSDATE,-1))) 
AND EXTRACT(MONTH FROM co.SENT_DATE) = Extract(MONTH FROM(ADD_MONTHS(SYSDATE,-1))) 
AND EXTRACT(YEAR FROM co.SENT_DATE) =Extract(YEAR FROM(ADD_MONTHS(SYSDATE,-1))) 

and co.CLEARINGHOUSE = 803

--and prs.CENTER = 223
--and prs.ID = 17478
--and prs.SUBID = 1

group by 
p.CENTER,
P.ID,
c.shortname,
p.FULLNAME,
prs.REQUESTED_AMOUNT,
pr.XFR_AMOUNT,
pr.req_date,
pr.REJECTED_REASON_CODE
--prs.center,
--prs.id,
--prs.subid
order by 
c.shortname,
p.FULLNAME) r2

ON r2.personId = r1.personId) ins
where ins.XFR_AMOUNT IS NULL

 


