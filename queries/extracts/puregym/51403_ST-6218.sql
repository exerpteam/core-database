SELECT
    TO_CHAR(longtodateC(pr.ENTRY_TIME,pr.center), 'YYYY-MM-DD') AS Request_Entry_Date
FROM
    PUREGYM.PAYMENT_REQUESTS pr
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
    AND ar.id = pr.id
WHERE
    longtodateC(pr.ENTRY_TIME,pr.center) <= TRUNC(SYSDATE -7)
    AND longtodateC(pr.ENTRY_TIME,pr.center) >= TRUNC(SYSDATE -31)
    AND pr.STATE IN (1,2)
    AND ar.CUSTOMERCENTER = $$member_center$$
    AND ar.CUSTOMERID = $$member_id$$