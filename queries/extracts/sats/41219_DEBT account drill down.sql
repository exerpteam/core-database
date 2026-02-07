 SELECT
     ar.CUSTOMERCENTER || 'p' ||    ar.CUSTOMERID pid,
     p.FULLNAME,
     longToDate(art.TRANS_TIME) TRANS_TIME,
     art.AMOUNT,
     art.DUE_DATE,
     art.INFO,
     art.TEXT,
     longToDate(art.ENTRY_TIME) ENTRY_TIME,
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
 join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.ID = ar.CUSTOMERID
 WHERE
     ar.AR_TYPE = 5
     and ar.CENTER in ($$scope$$)
