SELECT
    p.CENTER||'p'||p.id        AS MemberID,
    longtodate(art.ENTRY_TIME) AS "Log Date",
    art.TEXT,
    art.DUE_DATE,
    longtodate(art.TRANS_TIME) AS "Book Date",
    art.AMOUNT,
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') AS "Account Type",
    c.NAME                                           AS "Center Name"
FROM
    SATS.AR_TRANS art
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    art.CENTER = ar.CENTER
    AND art.id = ar.id
JOIN
    SATS.PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN
    SATS.CENTERS c
ON
    art.CENTER = c.ID
WHERE
    p.center IN ($$scope$$)
    AND art.TRANS_TIME BETWEEN 1388534400000 AND 1415719576000