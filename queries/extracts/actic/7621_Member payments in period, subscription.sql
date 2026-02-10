-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT t.* FROM
(
SELECT
    art.TRANS_TIME "TRANS_TIME",
    TO_CHAR(longtodate(art.TRANS_TIME), 'DD.MM.YYYY') "PAYMENT_DATE",
--	longtodate(art.entry_time),
    per.center || 'p' || per.id "MEMBER_ID",
    per.FIRSTNAME "FIRSTNAME",
    per.LASTNAME "LASTNAME",
    per.ADDRESS1 "ADDRESS1",
    per.ADDRESS2 "ADDRESS2",
    per.ZIPCODE "ZIPCODE",
    per.CITY "CITY",
    per.SSN "SSN",
    'Actic' || ' ' || club.SHORTNAME "CLUBNAME",
    club.ADDRESS1 "CLUBADD1",
    club.ADDRESS2 "CLUBADD2",
    club.ZIPCODE "CLUBZIP",
    club.CITY "CLUBCITY",
    prs.REF "REF",
    abs(art2.AMOUNT) as "AMOUNT",
    'ACTIC Sverige AB' "ORG_NAME", 
    'Box 1805' "ORG_ADDRESS", 
    '171 21 Solna' "ORG_ZIP_CITY", 
    '556494-3388' "ORG_NR",     
    '' "ORG_PHONE", 
    '' "ORG_CONTACT", 
    'Kvitto' "TITLE", 
    :coment "COMENT", 
    'Betaldag' "COL_DATE", 
    'Belopp' "COL_AMOUNT",     
    'Fakturanummer' "COL_REF"
FROM
    ACCOUNT_TRANS act
LEFT JOIN AR_TRANS art
ON
    art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid
    AND art.REF_TYPE = 'ACCOUNT_TRANS'
LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    art.center = prs.center
    AND art.id = prs.id
    AND art.INFO = prs.REF
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
    AND ar.id = art.id
JOIN PERSONS per
ON
    per.center = ar.CUSTOMERCENTER
    AND per.id = ar.CUSTOMERID
JOIN CENTERS club
ON
    per.center = club.ID


JOIN AR_TRANS art2
ON
    art2.PAYREQ_SPEC_CENTER = art.PAYREQ_SPEC_CENTER
    AND art2.PAYREQ_SPEC_ID = art.PAYREQ_SPEC_ID
    AND art2.PAYREQ_SPEC_SUBID = art.PAYREQ_SPEC_SUBID
    and art2.REF_TYPE in ('INVOICE','CREDIT_NOTE')
left JOIN INVOICES inv
ON
    inv.CENTER = art2.REF_CENTER
    AND inv.ID = art2.REF_ID
    AND art2.REF_TYPE = 'INVOICE'


WHERE
    act.INFO_TYPE IN (3, 4, 16)
  --  AND ar.CUSTOMERCENTER = 169
  --  and ar.CUSTOMERID = 908 
	AND (ar.CUSTOMERCENTER, ar.CUSTOMERID) in (:memberid)
    and inv.CENTER is not null
    AND inv.EMPLOYEE_CENTER IS NULL
    AND act.TRANS_TIME >= :FromDate
    AND act.TRANS_TIME < :ToDate + 1000*3600*24

UNION ALL

SELECT
    art.TRANS_TIME,
    TO_CHAR(longtodate(art.TRANS_TIME), 'DD.MM.YYYY') payment_Date,
--	longtodate(art.entry_time),
    per.center || 'p' || per.id member_id,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
    per.SSN,
    'Actic' || ' ' || club.SHORTNAME clubname,
    club.ADDRESS1 clubadd1,
    club.ADDRESS2 clubadd2,
    club.ZIPCODE clubzip,
    club.CITY clubcity,
    null,
    art2.AMOUNT,
    'Actic Sverige AB' ORG_NAME, 
    'Box 7270' ORG_ADDRESS, 
    '187 14 Täby' ORG_ZIP_CITY, 
    '556494-3388' ORG_NR,     
    '' ORG_PHONE, 
    '' ORG_CONTACT, 
    'Kvitto' TITLE, 
    :coment COMENT, 
    'Betaldag' COL_DATE, 
    'Belopp' COL_AMOUNT,     
    'Fakturanummer' COL_REF
FROM
    AR_TRANS art
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
    AND ar.id = art.id
JOIN PERSONS per
ON
    per.center = ar.CUSTOMERCENTER
    AND per.id = ar.CUSTOMERID
JOIN CENTERS club
ON
    per.center = club.ID


JOIN AR_TRANS art2
ON
    art2.PAYREQ_SPEC_CENTER = art.PAYREQ_SPEC_CENTER
    AND art2.PAYREQ_SPEC_ID = art.PAYREQ_SPEC_ID
    AND art2.PAYREQ_SPEC_SUBID = art.PAYREQ_SPEC_SUBID
    and art2.REF_TYPE in ('INVOICE','CREDIT_NOTE')
left JOIN INVOICES inv
ON
    inv.CENTER = art2.REF_CENTER
    AND inv.ID = art2.REF_ID
    AND art2.REF_TYPE = 'INVOICE'


WHERE
    ar.AR_TYPE = 4
 --   AND ar.CUSTOMERCENTER = 169
 --   and ar.CUSTOMERID = 908
	AND (ar.CUSTOMERCENTER, ar.CUSTOMERID) in (:memberid)
    AND art.TRANS_TIME >= :FromDate
    AND art.TRANS_TIME < :ToDate + 3600 * 1000 * 24
    AND art.AMOUNT > 0 AND substr(art.text, 1, 7) = 'Payment'
    AND art.EMPLOYEECENTER = 100 and art.EMPLOYEEID = 1
    and inv.CENTER is not null
   AND inv.EMPLOYEE_CENTER IS NULL
) t
ORDER BY 1 desc

