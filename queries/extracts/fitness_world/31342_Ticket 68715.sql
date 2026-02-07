-- This is the version from 2026-02-05
--  
SELECT
    p.CENTER || 'p' || p.ID pid,
	ar.ar_type,
	ar.center || 'ar' || ar.id ar_key,    
    prs.REF,
    inv.PAYER_CENTER || 'p' || inv.PAYER_ID payer_id,
    invl.PERSON_CENTER || 'p' || invl.PERSON_ID invl_pid,
    invl.TEXT,
    invl.TOTAL_AMOUNT
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
join AR_TRANS art on art.PAYREQ_SPEC_CENTER = prs.CENTER and art.PAYREQ_SPEC_ID = prs.ID and art.PAYREQ_SPEC_SUBID = prs.SUBID    
join ACCOUNT_RECEIVABLES ar on ar.CENTER = art.CENTER and ar.ID = art.ID
join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.ID = ar.CUSTOMERID
join INVOICES inv on inv.CENTER = art.REF_CENTER and art.REF_ID = inv.ID and art.REF_TYPE = 'INVOICE'
join INVOICELINES invl on invl.CENTER = inv.CENTER and invl.ID = inv.ID
WHERE
    prs.REF in ($$request_ref$$) 