SELECT
    p.center || 'p' || p.id  AS Member_ID,
    ccc.id || 'cc' || ccc.id    ccCaseId,
    ccr.REQ_DATE,CCR.REQ_AMOUNT,
    COUNT(*)
FROM
    PERSONS p
JOIN
    CASHCOLLECTIONCASES ccc
 ON
    p.CENTER = ccc.PERSONCENTER
    AND p.ID = ccc.PERSONID
JOIN
    CASHCOLLECTION_REQUESTS ccr
 ON
    ccr.CENTER = ccc.CENTER
    AND ccr.ID = ccc.ID
WHERE
    ccc.MISSINGPAYMENT = 1
    AND ccc.CLOSED = 1
    AND ccr.STATE = 0
  AND ccr.REQ_AMOUNT > 0
GROUP BY
    p.center,
    p.id,
    ccc.center,
    ccc.id,
    ccr.REQ_DATE,
    CCR.REQ_AMOUNT