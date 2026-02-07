SELECT
	'INVOICE' AS "Belegart",
	p.CENTER || 'inv' ||invl.id AS "Nr (invlineID)",
	p.CENTER || 'p' || p.ID AS "Auftraggeber Nr.",
	NULL "Zlg-Bedingungscode",
	TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') AS "Fälligkeitsdatum (Due)",
    CASE
WHEN comp.fullname IN('Nation Unis(UN)','Nation Unis (UN)')
THEN 'false'
ELSE 'true'
END AS "Preise inkl MWST",
	CASE
	WHEN p.center IN (1,5,88)THEN 'DE'
	WHEN p.center IN (3,4) THEN 'FR'
	ELSE NULL
	END AS "Sprachcode(lang)",
	NULL Buchungsnr,
	p.FULLNAME AS "Auftraggeber Name",
	p.co_name AS "Auftraggeber Name 2",
 
        CASE
        WHEN p.ADDRESS2 IS NOT NULL
        THEN p.ADDRESS1 || ', ' || p.ADDRESS2
        ELSE p.ADDRESS1
    END AS "Adresse",
	p.CITY AS "Auftraggeber Ort(City)",
    p.ZIPCODE AS "Auftraggeber PLZ(Zip)",
	TO_CHAR(pr.REQ_DATE, 'DD.MM.YYYY') AS "Belegdatum (req date)",
	CASE
WHEN comp.fullname IN('Nation Unis(UN)','Nation Unis (UN)')
THEN 'DIPLOMAT'
ELSE 'INLAND'
END AS "MWST-Geschäftsbuchungsgruppe",
	email.TXTVALUE AS "e_mail",

---additional info---
p.sex AS "Sex",
salut.txtvalue AS "Title",
comp.fullname AS "company",
ch.name AS "ClearingHouse",
CASE
WHEN ch.ctype IN (144,184)THEN 'CC'
WHEN ch.ctype IN (152) THEN 'LSV PLUS'
WHEN ch.ctype IN (178) THEN 'DD'
WHEN ch.ctype IN (154) THEN 'INV/SO'
ELSE 'Unknown'
END AS "PaymentType",

prs.open_amount AS "TotalOwed",
art.unsettled_amount AS "InvoiceBalance",
pr.state AS "PRstate",
prs.cancelled AS "PRcancelled"

    

FROM
    HP.PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    HP.AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
LEFT JOIN
	INVOICELINES invl
ON
	invl.CENTER = art.REF_CENTER
AND invl.ID = art.REF_ID
AND art.REF_TYPE = 'INVOICE'

JOIN
    HP.ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
JOIN
    HP.PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
JOIN
    centers c
ON 
    c.id = p.center

LEFT JOIN 
	PERSON_EXT_ATTRS salut
ON
    salut.PERSONCENTER = p.center
AND salut.personid = p.id
AND salut.name = '_eClub_Salutation'

LEFT JOIN
    HP.PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
    HP.PAYMENT_AGREEMENTS pa
ON
    pa.center = pr.CENTER
    AND pa.id = pr.ID
    AND pa.SUBID = pr.AGR_SUBID

LEFT JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.clearinghouse

  LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER ----Member of the company agreement
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
    AND rel.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.id = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID

LEFT JOIN
  PERSONS comp
ON
    comp.center = rel.RELATIVECENTER
    AND comp.id = rel.RELATIVEID



LEFT JOIN
    HP.PERSON_EXT_ATTRS home_phone
ON
    home_phone.PERSONCENTER=p.center
    AND home_phone.PERSONID=p.id
    AND home_phone.name='_eClub_PhoneHome'
LEFT JOIN
    HP.PERSON_EXT_ATTRS work_phone
ON
    work_phone.PERSONCENTER=p.center
    AND work_phone.PERSONID=p.id
    AND work_phone.name='_eClub_PhoneWork'
LEFT JOIN
    HP.PERSON_EXT_ATTRS mobile_phone
ON
    mobile_phone.PERSONCENTER=p.center
    AND mobile_phone.PERSONID=p.id
    AND mobile_phone.name='_eClub_PhoneSMS'
LEFT JOIN
    HP.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'
  
  
LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall1
ON
    debtCall1.PERSONCENTER=p.center
    AND debtCall1.PERSONID=p.id
    AND debtCall1.name='COMM_1.DEBT CALL'
    
    LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall2
ON
    debtCall2.PERSONCENTER=p.center
    AND debtCall2.PERSONID=p.id
    AND debtCall2.name='COMM_2.DEBT CALL'
    
    LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall3
ON
    debtCall3.PERSONCENTER=p.center
    AND debtCall3.PERSONID=p.id
    AND debtCall3.name='COMM_3.DEBT CALL'
    
    LEFT JOIN
    HP.PERSON_EXT_ATTRS debtComment
ON
    debtComment.PERSONCENTER=p.center
    AND debtComment.PERSONID=p.id
    AND debtComment.name='COMM_DEBT Comment'
    
WHERE
    prs.CENTER in (:Center)
	AND p.status in (:P_Status)
	AND ( (
            :D_Status = 1
            AND p.BLACKLISTED != 1 )
        OR (
            :D_Status = 2
            AND p.BLACKLISTED = 1 )
        OR (
            :D_Status = 3 ) )

    AND art.UNSETTLED_AMOUNT <> 0
    AND art.AMOUNT < 0
    --    AND prs.DUE_DATE >= '2013-01-01'
    --    AND prs.DUE_DATE <= '2013-01-31'
	AND pr.REQUEST_TYPE IN(1,6)    
	AND prs.ORIGINAL_DUE_DATE >= :DueDateFrom
    AND prs.ORIGINAL_DUE_DATE <= :DueDateTo
AND ch.ctype IN (:PaymentType)
	AND art.REF_TYPE = 'INVOICE'
    
ORDER BY
    p.center,
    p.id,
	P.CENTER || 'inv' ||invl.id,
    prs.ENTRY_TIME