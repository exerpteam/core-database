 select
 DISTINCT
 c.SHORTNAME, CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as persondId, p1.FULLNAME as nominativo,
 CASE pr.STATE  WHEN 1 THEN  'PS_NEW'  WHEN 2 THEN  'PS_SENT'  WHEN 3 THEN  'PS_DONE'  WHEN 5 THEN  'PS_REJECTED_BY_CLEARINGHOUSE'  WHEN 12 THEN  'PS_FAIL_NO_CREDITOR'  WHEN 17 THEN 'PS_FAIL_REJ_DEB_REVOKED' END "Stato",
   art.TEXT AS DescrizioneMovimento, invl.TEXT as ProdottoMovimento, REQUESTED_AMOUNT AS importoRid, invl.TOTAL_AMOUNT as importoMovimento, pr.REQ_DATE as scadenza
 FROM
         PERSONS p1
 INNER JOIN CENTERS c
 ON p1.CENTER = c.ID
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
 WHERE
 --PR.center = 102 AND
 c.COUNTRY = 'IT'
  and extract(month from pr.req_date) = EXTRACT(month FROM  ADD_MONTHS(CURRENT_TIMESTAMP,-1))
 and extract(year from  pr.req_date) = extract(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))
 and extract(day from pr.req_date) <= 2
 AND pr.STATE IS NOT NULL
 AND ART.REF_TYPE = 'INVOICE'
 AND invl.TOTAL_AMOUNT <> 0
 AND invl.TEXT != 'PT Family'
 AND art.COLLECTED_AMOUNT <> 0
 AND art.TEXT LIKE 'PT%'
 Order by CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8)))
