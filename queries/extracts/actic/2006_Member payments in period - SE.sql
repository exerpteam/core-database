SELECT
    per.center || 'p' || per.id member_id,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
    'Actic' || ' ' || club.SHORTNAME clubname,
    club.ADDRESS1 clubadd1,
    club.ADDRESS2 clubadd2,
    club.ZIPCODE clubzip,
    club.CITY clubcity,
    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') payment_Date,
    prs.REF,
    art.AMOUNT,
    'Nautilus Sport och Bad' ORG_NAME, 
    'Box 1224' ORG_ADDRESS, 
    '701 12 Örebro' ORG_ZIP_CITY, 
    '556494-3388' ORG_NR,     
    '' ORG_PHONE, 
    '' ORG_CONTACT, 
    'Kvitto' TITLE, 
    'Kvitto avser gjorda betalninger avseende ett Nautiluskort. I inbetalninarna ingår mervärdisskat on 6%.' COMENT, 
    'Betaldag' COL_DATE, 
    'Belopp' COL_AMOUNT,     
    'Fakturanummer' COL_REF
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
    act.INFO_TYPE IN (3, 16)
    AND (ar.CUSTOMERCENTER, ar.CUSTOMERID) in (:memberid)
    AND act.TRANS_TIME >= datetolong(TO_CHAR(:FromDate, 'YYYY-MM-DD HH24:MI'))
    AND act.TRANS_TIME < datetolong(TO_CHAR(:ToDate+1, 'YYYY-MM-DD HH24:MI'))

UNION ALL

SELECT
    per.center || 'p' || per.id member_id,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
    'Actic' || ' ' || club.SHORTNAME clubname,
    club.ADDRESS1 clubadd1,
    club.ADDRESS2 clubadd2,
    club.ZIPCODE clubzip,
    club.CITY clubcity,
    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') payment_Date,
    prs.REF,
    art.AMOUNT,
    'Nautilus Sport och Bad' ORG_NAME, 
    'Box 1224' ORG_ADDRESS, 
    '701 12 Örebro' ORG_ZIP_CITY, 
    '556494-3388' ORG_NR,     
    '' ORG_PHONE, 
    '' ORG_CONTACT, 
    'Kvitto' TITLE, 
    'Kvitto avser gjorda betalninger avseende ett Nautiluskort. I inbetalninarna ingår mervärdisskat on 6%.' COMENT, 
    'Betaldag' COL_DATE, 
    'Belopp' COL_AMOUNT,     
    'Fakturanummer' COL_REF
    
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
    act.INFO_TYPE IN (4)
    AND (ar.CUSTOMERCENTER, ar.CUSTOMERID) in (:memberid)
    AND act.TRANS_TIME >= datetolong(TO_CHAR(:FromDate, 'YYYY-MM-DD HH24:MI'))
    AND act.TRANS_TIME < datetolong(TO_CHAR(:ToDate+1, 'YYYY-MM-DD HH24:MI'))
