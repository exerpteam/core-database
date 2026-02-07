SELECT DISTINCT
    p.center||'p'||p.id        AS MemberID,
    longtodate(art.ENTRY_TIME) AS Log_Date,
    art.TEXT,
    art.DUE_DATE,
    longtodate(art.TRANS_TIME) AS Book_Date,
    art.AMOUNT,
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') AS "Account Type",
    c.NAME
FROM
    SATS.PERSONS p
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.id = p.id
    --   AND ar.AR_TYPE = 4
JOIN
    SATS.AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.id = ar.id
JOIN
    SATS.CENTERS c
ON
    c.ID = ar.CENTER
WHERE
    c.id IN(176) and art.TRANS_TIME>=datetolong('2014-01-01 00:00')