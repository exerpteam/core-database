SELECT
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
    p.FULLNAME,
    exerpro.longToDate(art.TRANS_TIME) TRANS_TIME,
    art.AMOUNT,
    art.DUE_DATE,
    art.INFO,
    art.TEXT,
    exerpro.longToDate(art.ENTRY_TIME) ENTRY_TIME,
    art.PAYREQ_SPEC_CENTER,
    art.PAYREQ_SPEC_ID,
    art.PAYREQ_SPEC_SUBID
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
AND ar.ID = art.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID
JOIN
    account_trans act
ON
    art.ref_center = act.center
AND art.REF_ID = act.ID
AND art.ref_subid = act.SUBID
AND art.ref_type = 'ACCOUNT_TRANS'
WHERE
    ar.AR_TYPE = 5
AND ar.CENTER IN ($$scope$$)
AND act.info_type = 4
AND act.INFO = $$File_ID$$