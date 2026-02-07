SELECT
	'INVOICE' AS "Belegart",
	prs.REF AS "Nr",
	NULL "Zeilennr.(line num pendng)",
	'G/L Account' AS "Art",
	'12345' AS "Nr.(pending)",
	art.TEXT AS "Beschreibung",
	inv.quantity AS "Menge(Quantity)",
	art.UNSETTLED_AMOUNT AS "VK-Preis(Inc VAT)",
	inv.net_amount AS "Betrag(Tot Net)",---wrong
	inv.rate AS "MWST-Produktbuchungsgruppe(VATrate)",--wrong
	trans.info AS "MWST-Produktbuchungsgruppe(VAT info)",---empty
	inv.total_amount AS "Zeilenbetrag(Tot amount)",---wrong
	comp.fullname AS "Company",---use to say case when in UN then vatrate 0


    p.CENTER || 'p' || p.ID AS "Auftraggeber Nr.",
    case pr.request_type
    when 1 then 'payment'
    when 6 then 'representation'
    else 'undefinded'
end as "Request Type",
TO_CHAR(pr.req_date, 'YYYY-MM-DD') AS "req date(delete dups)",
	TO_CHAR(pr.due_date, 'YYYY-MM-DD') AS "Fälligkeitsdatum (due date)",
pr.xfr_date AS "XFR DATE",
     
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
    debtComment.TXTVALUE debtComment
     
       
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
	INVOICELINES inv
ON
inv.center = pr.INV_COLL_CENTER
AND inv.id = pr.INV_COLL_ID
AND inv.subid =  pr.INV_COLL_SUBID

LEFT JOIN
	ACCOUNT_TRANS trans
ON
trans.center = inv.center
AND trans.id=inv.id
AND trans.subid=inv.subid


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
	AND p.status in (:PStatus)
	AND ( (
            :DStatus = 1
            AND p.BLACKLISTED != 1 )
        OR (
            :DStatus = 2
            AND p.BLACKLISTED = 1 )
        OR (
            :DStatus = 3 ) )

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