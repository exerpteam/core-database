-- The extract is extracted from Exerp on 2026-02-08
-- 1 line per invoice.
WITH
	PAY_REQUESTS AS
		(
			SELECT
				*
			FROM
				PAYMENT_REQUESTS pr
			WHERE
				pr.req_date = 	(
									SELECT
										MAX(pr_new.req_date)
									FROM
										PAYMENT_REQUESTS pr_new
									WHERE
										pr_new.CENTER = pr.CENTER
									AND	pr_new.ID = pr.ID
									AND     pr_new.state != 8
								)
		)



SELECT
	'INVOICE' AS "DocType",
	p.CENTER || 'inv' ||invl.id AS "Inv Nr",
	
	p.CENTER || 'p' || p.ID AS "Mem Nr",
	NULL "PaymentConditions",
	TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD') AS "DueDate",
'true' AS "Price inc VAT",
    
	CASE
	WHEN p.center IN (1,5,88)THEN 'DE'
	WHEN p.center IN (3,4) THEN 'FR'
	WHEN P.center IN (300) THEN 'FR'
	ELSE NULL
	END AS "Language",
	NULL "Booking Nr",
	p.FULLNAME AS "FullName",
	p.co_name AS "C/O Name",
 
        CASE
        WHEN p.ADDRESS2 IS NOT NULL
        THEN p.ADDRESS1 || ', ' || p.ADDRESS2
        ELSE p.ADDRESS1
    END AS "Address",
	p.CITY AS "City",
    p.ZIPCODE AS "Zip",
	TO_CHAR(pr.REQ_DATE,'YYYY-MM-DD') AS "ReceiptDate",
	CASE
	WHEN comp.fullname IN('Nation Unis(UN)','Nation Unis (UN)')
	THEN 'DIPLOMAT'
	ELSE 'INLAND'
	END AS "VAT Group",
	email.TXTVALUE AS "email",
	p.country as "Country",
	art.AMOUNT - art.UNSETTLED_AMOUNT AS "PaidAmount",
	salut.txtvalue AS "Title",

---additional info---
p.sex AS "Sex",
comp.fullname AS "company",
ch.name AS "ClearingHouse",
CASE
WHEN ch.ctype IN (144,184)THEN 'CC'
WHEN ch.ctype IN (152) THEN 'LSV PLUS'
WHEN ch.ctype IN (178) THEN 'DD'
WHEN ch.ctype IN (154) THEN 'INV/SO'
ELSE 'Unknown'
END AS "PaymentType",
case pr.request_type
    when 1 then 'payment'
    when 6 then 'representation'
    else 'undefinded'
END as "RequestType",
prs.open_amount AS "TotalOwed (PRopen)",
art.unsettled_amount AS "InvoiceBalance(unsettled)",
pcc.days_before_due AS "daystopay",
pr.state AS "PRstate",
prs.cancelled AS "PRcancelled"

    

FROM
   PAY_REQUESTS pr
LEFT JOIN 
	payment_request_specifications prs
ON 	PRS.CENTER = PR.INV_COLL_CENTER
AND PRS.ID = PR.INV_COLL_ID
AND PRS.SUBID = PR.INV_COLL_SUBID

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
	payment_cycle_config pcc
ON
pcc.ID = pa.payment_cycle_config_id

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
	AND pr.DUE_DATE >= :DueDateFrom
    AND pr.DUE_DATE <= :DueDateTo
AND ch.ctype IN (:PaymentType)
	AND art.REF_TYPE = 'INVOICE'
    

GROUP BY
p.CENTER,
invl.id,
prs.ref,
prs.ENTRY_TIME,
p.ID,
pr.DUE_DATE,
comp.fullname,
p.center,
p.FULLNAME,
p.co_name,
p.ADDRESS1,
p.ADDRESS2,
p.CITY,
p.ZIPCODE,
P.COUNTRY,
pr.REQ_DATE,
email.TXTVALUE,
p.sex,
salut.txtvalue,
ch.name,
ch.ctype,
pr.request_type,
prs.open_amount,
art.AMOUNT,
art.unsettled_amount,
pcc.days_before_due,
pr.state,
prs.cancelled


ORDER BY

    p.center,
    p.id,
	invl.id,
    prs.REF,
	prs.ENTRY_TIME

