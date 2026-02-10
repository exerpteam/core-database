-- The extract is extracted from Exerp on 2026-02-08
--  
 select
 DISTINCT
 c.SHORTNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId, p.FULLNAME as nominativo,
  REQUESTED_AMOUNT AS importoRichiesto, art.TEXT AS Testo,
 LongToDate(art.ENTRY_TIME) as dataPagamento,
 pr.REQ_DATE as DataRichiesta
 FROM
         PERSONS p
 JOIN CENTERS c
 ON p.CENTER = c.ID
 JOIN
 ACCOUNT_RECEIVABLES ar
 on
  ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
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
 AND invl.CENTER = art.REF_CENTER WHERE art.TEXT LIKE 'Manual registered payment of request%'
 AND c.COUNTRY = 'IT'
 AND LongToDate(art.ENTRY_TIME) BETWEEN $$dataDa$$ AND $$dataA$$ + 1
 ORDER BY c.SHORTNAME, p.FULLNAME
