/**
* Creator: Exerp
* Purpose: List recurring payment for given period and center.
*/
SELECT
    row_number() over() line,
    club.SHORTNAME clubname,
    per.center || 'p' || per.id member_id,
    per.FIRSTNAME,
    per.LASTNAME,
    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') payment_Date,
    art.AMOUNT,
    CASE
        WHEN act.INFO_TYPE IN (3, 16)
        THEN 'AG/Faktura'
        WHEN act.INFO_TYPE IN (4)
        THEN 'Ekstern'
        ELSE 'Unknown'
    END as type
FROM
    ACCOUNT_TRANS act
LEFT JOIN AR_TRANS art
ON
    art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid
    AND art.REF_TYPE = 'ACCOUNT_TRANS'
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
    act.INFO_TYPE IN (3, 16, 4)
    AND act.center IN ( :ChosenScope )
    AND act.TRANS_TIME >= :FromDate
    AND act.TRANS_TIME < :ToDate + (1000*60*60*24)
