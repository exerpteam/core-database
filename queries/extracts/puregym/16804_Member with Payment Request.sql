-- The extract is extracted from Exerp on 2026-02-08
-- ST-6218
SELECT
    TO_CHAR(longtodateC(pr.ENTRY_TIME,pr.center), 'YYYY-MM-DD') AS Request_Entry_Date
FROM
    PUREGYM.PAYMENT_REQUESTS pr
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.CENTER
    AND ar.ID = pr.ID
JOIN
    PUREGYM.PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = pr.INV_COLL_CENTER
    AND prs.ID = pr.INV_COLL_ID
    AND prs.SUBID = pr.INV_COLL_SUBID
JOIN
    PUREGYM.PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
WHERE
    longtodateC(prs.ENTRY_TIME,pr.center) >= TRUNC(SYSDATE -7)
    AND longtodateC(prs.ENTRY_TIME,pr.center) <= TRUNC(SYSDATE +31)
    AND pr.STATE IN (1,2)
    AND p.EXTERNAL_ID = $$member_external_id$$
AND pr.REQUEST_TYPE in (1,5,6)