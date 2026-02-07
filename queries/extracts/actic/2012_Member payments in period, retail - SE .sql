SELECT * FROM
(SELECT
    art.TRANS_TIME as "TRANS_TIME",
    TO_CHAR(longtodate(art.TRANS_TIME), 'DD.MM.YYYY') as "PAYMENT_DATE",
    per.center || 'p' || per.id as "MEMBER_ID",
    per.FIRSTNAME as "FIRSTNAME",
    per.LASTNAME as "LASTNAME",
    per.ADDRESS1 as "ADDRESS1",
    per.ADDRESS2 as "ADDRESS2",
    per.ZIPCODE as "ZIPCODE",
    per.CITY as "CITY",
    per.SSN as "SSN",
    'Actic' || ' ' || club.SHORTNAME as "CLUBNAME",
    club.ADDRESS1 as "CLUBADD1",
    club.ADDRESS2 as "CLUBADD2",
    club.ZIPCODE as "CLUBZIP",
    club.CITY as "CLUBCITY",
    prs.REF as "REF",
    art.AMOUNT as "AMOUNT",
    'ACTIC Sverige AB' as "ORG_NAME", 
    'Box 1805' as "ORG_ADDRESS", 
    '171 21 Solna' as "ORG_ZIP_CITY", 
    '556494-3388' as "ORG_NR",     
    '' as "ORG_PHONE", 
    '' as "ORG_CONTACT", 
    'Kvitto' as "TITLE", 
    :coment as "COMENT", 
    'Betaldag' as "COL_DATE", 
    'Belopp' as "COL_AMOUNT",     
    'Fakturanummer' as "COL_REF"
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
WHERE
    act.INFO_TYPE IN (3, 4, 16)
    AND (ar.CUSTOMERCENTER, ar.CUSTOMERID) in (:memberid)
    AND act.TRANS_TIME >= :FromDate
    AND act.TRANS_TIME < :ToDate + 1000*3600*24

UNION ALL

SELECT
    art.TRANS_TIME,
    TO_CHAR(longtodate(art.TRANS_TIME), 'DD.MM.YYYY') payment_Date,
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
    art.AMOUNT,
    'Actic Sverige AB' ORG_NAME, 
    'Box 1805' ORG_ADDRESS, 
    '171 21 Solna' ORG_ZIP_CITY, 
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
WHERE
    ar.AR_TYPE = 4
	AND (ar.CUSTOMERCENTER, ar.CUSTOMERID) in (:memberid)
    AND art.TRANS_TIME >= :FromDate
    AND art.TRANS_TIME < :ToDate + 3600 * 1000 * 24
    AND art.AMOUNT > 0 AND substr(art.text, 1, 7) = 'Payment'
    AND art.EMPLOYEECENTER = 100 and art.EMPLOYEEID = 1
) t
ORDER BY 1 desc
