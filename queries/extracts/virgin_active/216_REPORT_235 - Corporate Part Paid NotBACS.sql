SELECT
    comp.LASTNAME COMAPNY_NAME,
    comp.CENTER || 'p' || comp.ID comp_id,
    ca.NAME AGREEMENT_NAME,
    p.CENTER || 'p' || p.ID pid,
    p.FULLNAME person_name,
    longToDate(inv.TRANS_TIME) INV_CREATED,
    invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID invl_id,
    prod.NAME PRODUCT_NAME,
    invl.QUANTITY,
    invl.TOTAL_AMOUNT MEMBER_AMOUNT,
    invls.TOTAL_AMOUNT SPONSORED_AMOUNT,
    cnl.TOTAL_AMOUNT CREDITED_AMOUNT,
    cnls.TOTAL_AMOUNT SPONSORED_CREDITED_AMOUNT ,
    CASE
        WHEN art.CENTER IS NULL
        THEN 'CASH'
        WHEN
            (
                ar.CUSTOMERCENTER,ar.CUSTOMERID
            )
            NOT IN ((p.CENTER,p.ID))
        THEN 'OTHER_PAYER'
        WHEN ar.AR_TYPE = 1
        THEN 'CASH_ACCOUNT'
        ELSE ch.NAME
    END AS PAID_BY
FROM
    RELATIVES rel
LEFT JOIN STATE_CHANGE_LOG scl
ON
    scl.CENTER = rel.CENTER
    AND scl.ID = rel.ID
    AND scl.SUBID = rel.SUBID
    AND scl.ENTRY_TYPE = 4
    AND scl.STATEID = rel.STATUS
    AND scl.BOOK_END_TIME IS NULL
JOIN PERSONS p
ON
    p.CENTER = rel.CENTER
    AND p.id = rel.id
JOIN PERSONS comp
ON
    comp.CENTER = rel.RELATIVECENTER
    AND comp.ID = rel.RELATIVEID
JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.ID = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
LEFT JOIN INVOICELINES invl
ON
    invl.PERSON_CENTER = p.CENTER
    AND invl.PERSON_ID = p.ID
LEFT JOIN INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN INVOICELINES invls
ON
    invls.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND invls.ID = inv.SPONSOR_INVOICE_ID
    AND invls.SUBID = invl.SPONSOR_INVOICE_SUBID
LEFT JOIN CREDIT_NOTE_LINES cnl
ON
    cnl.INVOICELINE_CENTER = invl.CENTER
    AND cnl.INVOICELINE_ID = invl.ID
    AND cnl.INVOICELINE_SUBID = invl.SUBID
LEFT JOIN CREDIT_NOTE_LINES cnls
ON
    cnls.INVOICELINE_CENTER = invls.CENTER
    AND cnls.INVOICELINE_ID = invls.ID
    AND cnls.INVOICELINE_SUBID = invls.SUBID
LEFT JOIN AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = inv.CENTER
    AND art.REF_ID = inv.ID
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
LEFT JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN PAYMENT_AGREEMENTS pagr
ON
    pagr.CENTER = pac.ACTIVE_AGR_CENTER
    AND pagr.ID = pac.ACTIVE_AGR_ID
    AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN CLEARINGHOUSES ch
ON
    ch.ID = pagr.CLEARINGHOUSE
LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
    AND prs.ID = art.PAYREQ_SPEC_ID
    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
WHERE
    rel.RTYPE = 3
    AND rel.STATUS = 1
	AND inv.TRANS_TIME BETWEEN :fromDate AND :toDate + (1000*60*60*24)
	and p.center in (:scope)
    /*
	AND inv.TRANS_TIME BETWEEN dateToLong('2014-09-25 00:00') AND dateToLong('2014-10-01 00:00')

    and invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID = '401inv12292ln3'
    and p.CENTER || 'p' || p.id = '401p771' */