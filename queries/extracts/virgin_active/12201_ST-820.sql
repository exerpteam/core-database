SELECT
    c.SHORTNAME CENTER_NAME,
    art.AMOUNT,
    longToDate(art.TRANS_TIME)            TRANS_TIME,
    DECODE(AR_TYPE,1,'Cash',4,'Payment',5,'Debt') ACCOUNT_TYPE,
    p.CENTER || 'p' || p.ID                       pid,
    p.FULLNAME,
    floor(months_between(SYSDATE, p.BIRTHDATE) / 12)  PAYER_AGE,
    nvl2(rel.CENTER,1,0)                              IS_OTHER_PAYER,
    op.CENTER || 'p' || op.ID                         paid_PID,
    floor(months_between(SYSDATE, op.BIRTHDATE) / 12) PAID_AGE
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
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 12
    AND rel.STATUS = 1
LEFT JOIN
    PERSONS op
ON
    op.CENTER = rel.RELATIVECENTER
    AND op.ID = rel.RELATIVEID
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
WHERE
    art.TEXT = 'Migrated & Historical Debt write off, not recoverable, authorised by Finance'
and art.center in ($$scope$$)