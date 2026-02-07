select
CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as persondId, p1.FULLNAME as nominativo, prs.REF as IDFATTURA, 
DECODE(pr.STATE, 1, 'PS_NEW', 2, 'PS_SENT', 3, 'PS_DONE', 5, 'PS_REJECTED_BY_CLEARINGHOUSE', 12, 'PS_FAIL_NO_CREDITOR', 17,'PS_FAIL_REJ_DEB_REVOKED') "Stato", PR.STATE,
 REQUESTED_AMOUNT AS importoRichiesto, art.TEXT AS DescrizioneMovimento, invl.TEXT as ProdottoMovimento, invl.TOTAL_AMOUNT as importoMovimento, pr.REQ_DATE as scadenza, e.EMAILADDRESS as Email, p1.ADDRESS1 as Indirizzo1, p1.CITY
as citta, p1.ZIPCODE as cap, c.COMM as Piva,ico.INVOICECONAME as CO, ia1.INVOICEADDRESS1 as inidrizzoFattura1, ia2.INVOICEADDRESS2 as indirizzoFattura2, ie.INVOICEEMAIL as emailFattura, ic.INVOICECITY AS cittaFattura, iz.INVOICEZIPCODE as capFattura
 
 
 
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

LEFT JOIN (SELECT
  p.center,
  p.id,
   
    atts.TXTVALUE "EMAILADDRESS"
   
FROM
    PERSON_EXT_ATTRS atts
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'E_MAIL'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'COMMENT'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICEADDRESS2'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICEADDRESS2'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICECITY'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICECONAME'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICECOUNTRY'
WHERE
    atts.NAME = '_eClub_InvoiceCountry'
	and p.SEX != 'C'
	and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
   
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICEEMAIL'
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
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = 'INVOICEZIPCODE'
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
pr.center IN(select c.ID from CENTERS c where  c.COUNTRY = 'IT') and extract(month from pr.req_date) = EXTRACT(month FROM  ADD_MONTHS(SYSDATE,-14))
and extract(year from  pr.req_date) = extract(YEAR FROM ADD_MONTHS(SYSDATE,-14))
and extract(day from pr.req_date) <= 2
AND pr.STATE IS NOT NULL
AND ART.REF_TYPE = 'INVOICE'
--AND ar.CUSTOMERID = 7338
AND art.COLLECTED_AMOUNT <> 0


Order by P1.CENTER, P1.FULLNAME





