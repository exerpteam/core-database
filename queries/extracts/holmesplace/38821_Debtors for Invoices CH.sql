-- The extract is extracted from Exerp on 2026-02-08
-- Based on Overdue debt: Lawyer
SELECT
	'INVOICE' AS "Belegart",
	prs.REF AS "Nr",
    p.CENTER || 'p' || p.ID AS "Auftraggeber Nr.",
	NULL "Zlg-Bedingungscode",
	TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') AS "Fälligkeitsdatum (Due)",
    'TRUE' AS "Preise inkl MWST",
	CASE
	WHEN p.center IN (1,5,88)THEN 'DE'
	WHEN p.center IN (3,4) THEN 'FR'
	ELSE NULL
	END AS "Sprachcode(lang)",
	NULL Buchungsnr,
	P.FULLNAME AS "Auftraggeber Name",
	NULL "Auftraggeber Name 2",
 
        CASE
        WHEN p.ADDRESS2 IS NOT NULL
        THEN p.ADDRESS1 || ', ' || p.ADDRESS2
        ELSE p.ADDRESS1
    END AS "Adresse",
	P.CITY AS "Auftraggeber Ort(City)",
    p.ZIPCODE AS "Auftraggeber PLZ(Zip)",
	TO_CHAR(pr.REQ_DATE, 'DD.MM.YYYY') AS "Belegdatum (req date)",
	'INLAND' AS "MWST-Geschäftsbuchungsgruppe",
	email.TXTVALUE AS "e_mail",
    
TO_CHAR(longtodate(art.ENTRY_TIME), 'YYYY-MM-DD')AS "entrydate",
	art.TEXT AS "Description",
    art.UNSETTLED_AMOUNT AS "UnsettledAmount",
	p.blacklisted,
	pa.CREDITOR_ID AS "creditor",
        case p.status
        when 0 then 'lead'
        when 1 then 'active'
        when 2 then 'inactive'
        when 3 then 'temp inactive'
        when 4 then 'transferred'
        when 5 then 'duplicate'
        when 6 then 'prospect'
        when 7 then 'blocked'
        when 8 then 'anonymized'
        when 9 then 'contact'
        else 'undefined'
    end as "PersonStatus",
    
    prs.REQUESTED_AMOUNT AS "Requestd_Amount",
    art.AMOUNT - art.UNSETTLED_AMOUNT AS "SettledAmount",
    ar.BALANCE AS "Balance",
    debtCall1.TXTVALUE debtCall1,
    debtCall2.TXTVALUE debtCall2,
    debtCall3.TXTVALUE debtCall3,
    debtComment.TXTVALUE debtComment,
     
    
    (
        SELECT DISTINCT
            TO_CHAR(sub.BINDING_END_DATE, 'DD.MM.YYYY')
        FROM
            HP.INVOICELINES il
        JOIN
            HP.SPP_INVOICELINES_LINK sppil
        ON
            sppil.INVOICELINE_CENTER = il.CENTER
            AND sppil.INVOICELINE_ID = il.ID
            AND sppil.INVOICELINE_SUBID = il.SUBID
        JOIN
            HP.SUBSCRIPTIONS sub
        ON
            sub.CENTER = sppil.PERIOD_CENTER
            AND sub.ID = sppil.PERIOD_ID
        WHERE
            il.CENTER = art.REF_CENTER
            AND il.ID = art.REF_ID
            AND il.SUBID = art.REF_SUBID
            AND art.REF_TYPE = 'INVOICE') binding_date
    
    
FROM
    HP.PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    HP.AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
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
    AND art.UNSETTLED_AMOUNT <> 0
    AND art.AMOUNT < 0
    --    AND prs.DUE_DATE >= '2013-01-01'
    --    AND prs.DUE_DATE <= '2013-01-31'
	AND pr.REQUEST_TYPE IN(1,6)    
	AND prs.ORIGINAL_DUE_DATE >= :DueDateFrom
    AND prs.ORIGINAL_DUE_DATE <= :DueDateTo
    AND art.REF_TYPE = 'INVOICE'
    
ORDER BY
    p.center,
    p.id,
    prs.ENTRY_TIME