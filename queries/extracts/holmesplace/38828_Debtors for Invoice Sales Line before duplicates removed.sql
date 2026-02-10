-- The extract is extracted from Exerp on 2026-02-08
-- with DIPLOMAT vat rate and name changed to 0
Added days before due from payment cycle config as extra column, maybe use for Zlg-Bedingungscode column
SELECT
	'INVOICE' AS "Belegart(OK)",
	P.CENTER || 'inv' ||invl.id AS "Nr (invlineID)",
	invl.subid AS "Zeilennr.(EXERP)",---ok now
	'G/L Account' AS "Art (OK)",
	'12345' AS "Nr.(pening number from Thomas)",
	trans.TEXT AS "Beschreibung (OK)",
	invl.quantity AS "Menge(Quantity EXERP)",---missing 1
	invl.TOTAL_AMOUNT AS "VK-Preis(Inc VAT OK)",
CASE comp.fullname
WHEN 'Nation Unis (UN)' then invl.TOTAL_AMOUNT
ELSE invl.net_amount 
END AS "Betrag(Tot Net EXERP)",---ok inc VAT if company is 'Nation Unis (UN)'
CASE comp.fullname
WHEN 'Nation Unis (UN)' then '0'
ELSE invl.rate*100 
END AS "MWST-Produktbuchungsgruppe(VATrate)",--ok  should be 0% if Diplomat
CASE comp.fullname
WHEN 'Nation Unis (UN)' then 'VAT-SALES 0%'
ELSE vt.name 
END AS "MWST-Produktbuchungsgruppe(VAT)",---ok should be SALES 0%  if Diplomat
	prs.open_amount AS "Zeilenbetrag(Tot amount PRopenamount)",---ok
	comp.fullname AS "Company (OK)",---use to say case when in UN then vat rate 0

---ADDITIONAL INFORMATION OK FOR NOW
    p.CENTER || 'p' || p.ID AS "Auftraggeber Nr. (OK)",
	prs.REF AS "Nr (prref)",
    case pr.request_type
    when 1 then 'payment'
    when 6 then 'representation'
    else 'undefinded'
end as "Request Type (OK)",
TO_CHAR(pr.req_date, 'YYYY-MM-DD') AS "req date(OK)",
	TO_CHAR(pr.due_date, 'YYYY-MM-DD') AS "Fälligkeitsdatum (due date)",
    pr.req_amount AS "RequestedAmount",---no good for companines if they paid some for some members but not all
	p.blacklisted,
	ch.name AS "ClearingHouse",
CASE
WHEN ch.ctype IN (144,184)THEN 'CC'
WHEN ch.ctype IN (152) THEN 'LSV PLUS'
WHEN ch.ctype IN (178) THEN 'DD'
WHEN ch.ctype IN (154) THEN 'INV/SO'
ELSE 'Unknown'
END AS "PaymentType",

pcc.days_before_due AS "daystopay",

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
        else 'unknown'
    end as "PersonStatus",
    CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS "PersonType",
    prs.REQUESTED_AMOUNT AS "Requestd_Amount",
	art.AMOUNT - art.UNSETTLED_AMOUNT AS "SettledAmount",
    ar.BALANCE AS "Balance",
    debtCall1.TXTVALUE debtCall1,
    debtCall2.TXTVALUE debtCall2,
    debtCall3.TXTVALUE debtCall3,
    debtComment.TXTVALUE debtComment
         
FROM
   PAYMENT_REQUESTS pr

LEFT JOIN
	ACCOUNT_RECEIVABLES ar
ON
	ar.CENTER = pr.CENTER
AND	ar.ID = pr.ID

LEFT JOIN
	PERSONS p
ON
	p.CENTER = ar.CUSTOMERCENTER
AND	p.ID = ar.CUSTOMERID

LEFT JOIN 
	payment_request_specifications prs
ON 	PRS.CENTER = PR.INV_COLL_CENTER
AND PRS.ID = PR.INV_COLL_ID
AND PRS.SUBID = PR.INV_COLL_SUBID

LEFT JOIN
	AR_TRANS art
ON
	art.payreq_spec_center = prs.CENTER
AND	art.payreq_spec_id = prs.ID
AND	art.payreq_spec_subid = prs.SUBID

LEFT JOIN
	INVOICELINES invl
ON
	invl.CENTER = art.REF_CENTER
AND invl.ID = art.REF_ID
AND art.REF_TYPE = 'INVOICE'

LEFT JOIN
	ACCOUNT_TRANS trans
ON 
	trans.center = invl.account_trans_center
AND trans.id= invl.account_trans_id
AND trans.subid= invl.account_trans_subid

LEFT JOIN
        account_vat_type_group avtg
ON
        avtg.account_center = trans.credit_accountcenter
AND     avtg.account_id = trans.credit_accountid

LEFT JOIN
        account_vat_type_link avtl
ON
        avtl.account_vat_type_group_id = avtg.ID

LEFT JOIN
        vat_types vt
ON
        vt.CENTER = avtl.vat_type_center
AND     vt.ID = avtl.vat_type_id

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
    CLEARINGHOUSES ch
ON
    ch.ID = pa.clearinghouse

LEFT JOIN
	payment_cycle_config pcc
ON
pcc.ID = pa.payment_cycle_config_id


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
    --    AND prs.DUE_DATE >= '2013-01-01'--change selection to req date instad of due date to exclude represenations done on 1st of following month?
    --    AND prs.DUE_DATE <= '2013-01-31'
	AND pr.REQUEST_TYPE IN(1,6)    
	AND prs.ORIGINAL_DUE_DATE >= :DueDateFrom
    AND prs.ORIGINAL_DUE_DATE <= :DueDateTo
    AND ch.ctype IN (:PaymentType)

    --AND art.REF_TYPE = 'INVOICE'--if I change amount to invl.total_amount will need to add credit notes to the list!
    
ORDER BY
    p.center,
    p.id,
    P.CENTER || 'inv' ||invl.id,
	pr.req_date,
	invl.subid
