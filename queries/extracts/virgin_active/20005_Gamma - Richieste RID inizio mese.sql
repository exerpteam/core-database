-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            EXTRACT(MONTH FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1)) AS sel_month,
            EXTRACT(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))  AS sel_year
    )

 select
 DISTINCT
 CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as "PERSONID", p1.FULLNAME as "NOMINATIVO", prs.REF as "IDFATTURA",
 CASE pr.STATE  WHEN 1 THEN  'PS_NEW'  WHEN 2 THEN  'PS_SENT'  WHEN 3 THEN  'PS_DONE'  WHEN 5 THEN  'PS_REJECTED_BY_CLEARINGHOUSE'  WHEN 12 THEN  'PS_FAIL_NO_CREDITOR'  WHEN 17 THEN 'PS_FAIL_REJ_DEB_REVOKED' END "Stato", PR.STATE AS "STATE",
  REQUESTED_AMOUNT AS "IMPORTORICHIESTO", art.TEXT AS "DESCRIZIONEMOVIMENT", invl.TEXT as "PRODOTTOMOVIMENTO", invl.TOTAL_AMOUNT as "IMPORTOMOVIMENTO", pr.REQ_DATE as "SCADENZA", e."EMAILADDRESS" as "EMAIL", p1.ADDRESS1 as "INDIRIZZO1", p1.CITY
 as "CITTA", p1.ZIPCODE as "CAP", CASE WHEN LENGTH(c."COMM") = 0 OR c."COMM" IS NULL THEN '00000000000' ELSE c."COMM" END as "PIVA",ico."INVOICECONAME" as "CO", ia1."INVOICEADDRESS1" as "INIDRIZZOFATTURA1", ia2."INVOICEADDRESS2" as "INIDRIZZOFATTURA2", ie."INVOICEEMAIL" as "EMAILFATTURA", ic."INVOICECITY" AS "CITTAFATTURA", iz."INVOICEZIPCODE" as "CAPFATTURA"
 FROM
         params par,
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
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "EMAILADDRESS"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_Email'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) e
 ON e.center = p1.center
 and e.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "COMM"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_Comment'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) c
 ON c.center = p1.center
 and c.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICEADDRESS1"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_InvoiceAddress1'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) ia1
 ON ia1.center = p1.center
 and ia1.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICEADDRESS2"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_InvoiceAddress2'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) ia2
 ON ia2.ID = p1.ID
 AND ia2.CENTER = p1.CENTER
         LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICECITY"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_InvoiceCity'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) ic
 ON ic.center = p1.center
 and ic.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICECONAME"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_InvoiceCoName'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) ico
 ON ico.center = p1.center
 and ico.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICECOUNTRY"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) icou
 ON icou.center = p1.center
 and icou.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICEEMAIL"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_InvoiceEmail'
         and p.SEX != 'C'
         and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) ie
 ON ie.center = p1.center
 and ie.id = p1.id
 LEFT JOIN (SELECT
   p.center,
   p.id,
     atts.TXTVALUE "INVOICEZIPCODE"
 FROM
     PERSON_EXT_ATTRS atts
 JOIN PERSONS p
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
 WHERE
     atts.NAME = '_eClub_InvoiceZipCode'
         and p.SEX != 'C'
         and p.center IN( select c.ID from CENTERS c where  c.COUNTRY = 'IT'  )
 GROUP BY
         p.center,
     p.id,
     atts.TXTVALUE) iz
 ON iz.center = p1.center
 and iz.id = p1.id
 WHERE
 --PR.center = 102 AND
 pr.center IN(select c.ID from CENTERS c where  c.COUNTRY = 'IT')
  and extract(month from pr.req_date) = par.sel_month
 and extract(year from  pr.req_date) = par.sel_year
 --and extract(day from pr.req_date) <= 2
 and extract(day from pr.req_date) <= 4
 AND pr.STATE IS NOT NULL
 AND ART.REF_TYPE = 'INVOICE'
 AND art.COLLECTED_AMOUNT <> 0
 Order by CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8)))
