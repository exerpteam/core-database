-- The extract is extracted from Exerp on 2026-02-08
--  
select DISTINCT
       CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as persondId
       , p1.FULLNAME as nominativo
       , prs.REF as IDFATTURA
       , DECODE(pr.STATE, 1, 'PS_NEW', 2, 'PS_SENT', 3, 'PS_DONE', 5, 'PS_REJECTED_BY_CLEARINGHOUSE', 12, 'PS_FAIL_NO_CREDITOR', 17,'PS_FAIL_REJ_DEB_REVOKED') "Stato"
       , PR.STATE
       , REQUESTED_AMOUNT AS importoRichiesto
       , art.TEXT AS DescrizioneMovimento
       , invl.TEXT as ProdottoMovimento
       , invl.TOTAL_AMOUNT as importoMovimento
       , pr.REQ_DATE as scadenza
       , e.EMAILADDRESS as Email
       , p1.ADDRESS1 as Indirizzo1
       , p1.CITY as citta
       , p1.ZIPCODE as cap
       , CASE
             WHEN LENGTH(c.COMM) = 0 OR c.COMM IS NULL THEN '00000000000'
             ELSE c.COMM
             END as Piva
       , ico.INVOICECONAME as CO
FROM
       PERSONS p1
JOIN
       ACCOUNT_RECEIVABLES ar
on
       ar.CUSTOMERCENTER = p1.CENTER
    AND ar.CUSTOMERID = p1.ID
       AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
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
LEFT JOIN
       AR_TRANS art
ON
       art.PAYREQ_SPEC_SUBID = prs.SUBID
    and art.PAYREQ_SPEC_ID = prs.ID
    and art.PAYREQ_SPEC_CENTER = prs.CENTER
LEFT JOIN
       INVOICELINES invl
on
       invl.ID = art.REF_ID
       AND invl.CENTER = art.REF_CENTER
LEFT JOIN
(
       SELECT
             p.center
             , p.id
             , atts.TXTVALUE "EMAILADDRESS"
       FROM
             PERSON_EXT_ATTRS atts
       JOIN
             PERSONS p
       ON
             p.CENTER = atts.PERSONCENTER
             AND p.ID = atts.PERSONID
       WHERE
             atts.NAME = '_eClub_Email'
             and p.SEX != 'C'
             and p.center IN (select c.ID from CENTERS c where c.COUNTRY = 'IT')
       GROUP BY
             p.center
             , p.id
             , atts.TXTVALUE
) e
ON
       e.center = p1.center
       and e.id = p1.id
LEFT JOIN
(
       SELECT
             p.center
             , p.id
             , atts.TXTVALUE "COMM"
       FROM
             PERSON_EXT_ATTRS atts
       JOIN
             PERSONS p
       ON
             p.CENTER = atts.PERSONCENTER
             AND p.ID = atts.PERSONID
       WHERE
             atts.NAME = '_eClub_Comment'
             and p.SEX != 'C'
             and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
       GROUP BY
             p.center
             , p.id
             , atts.TXTVALUE
) c
ON
       c.center = p1.center
       and c.id = p1.id
LEFT JOIN
(
       SELECT
             p.center
             , p.id
             , atts.TXTVALUE "INVOICECONAME"
       FROM
             PERSON_EXT_ATTRS atts
       JOIN
             PERSONS p
       ON
             p.CENTER = atts.PERSONCENTER
             AND p.ID = atts.PERSONID
       WHERE
             atts.NAME = '_eClub_InvoiceCoName'
             and p.SEX != 'C'
             and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
       GROUP BY
             p.center
             , p.id
             , atts.TXTVALUE
) ico
ON
       ico.center = p1.center
       and ico.id = p1.id
 
WHERE
--PR.center = 102 AND
       pr.center IN(select c.ID from CENTERS c where  c.COUNTRY = 'IT')
       and extract(month from pr.req_date) = EXTRACT(month FROM  ADD_MONTHS(SYSDATE,0))
       and extract(year from  pr.req_date) = extract(YEAR FROM ADD_MONTHS(SYSDATE,0))
       and extract(day from pr.req_date) <= 5
       AND pr.STATE IS NOT NULL
       AND ART.REF_TYPE = 'INVOICE'
       AND art.COLLECTED_AMOUNT <> 0