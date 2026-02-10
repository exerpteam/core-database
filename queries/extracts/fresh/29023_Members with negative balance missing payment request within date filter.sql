-- The extract is extracted from Exerp on 2026-02-08
-- EC-10218
SELECT
ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
ar.balance

FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    persons p
ON
    p.center = ar.customercenter
    and p.id = ar.customerid  

WHERE
p.center in (:scope)
AND  ar.AR_TYPE = 4
AND  ar.balance <= -1

AND NOT EXISTS (
    SELECT 1
    FROM PAYMENT_REQUEST_SPECIFICATIONS prs
    JOIN PAYMENT_REQUESTS pr
        ON pr.INV_COLL_CENTER = prs.CENTER
       AND pr.INV_COLL_ID     = prs.ID
       AND pr.INV_COLL_SUBID  = prs.SUBID
    WHERE prs.CENTER = ar.CENTER
      AND prs.ID     = ar.ID
AND  pr.REQ_DATE between :from_date and :to_date
);