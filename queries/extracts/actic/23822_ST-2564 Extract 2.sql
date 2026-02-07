SELECT
    longtodateC(art.TRANS_TIME,art.CENTER) AS BOOK_DATE,
    longtodateC(art.ENTRY_TIME,art.CENTER) AS ENTRY_DATE,
    art.AMOUNT,
    art.TEXT,
    art.CENTER,
    ar.CUSTOMERCENTER || 'p' || ar.customerid AS MemberId
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    art.center = ar.center
AND art.id = ar.id
AND ar.AR_TYPE = 6
WHERE
    trans_time >= $$cutDate$$
AND entry_time < $$cutDate$$
and art.CENTER in ($$scope$$)
ORDER BY
    entry_time