-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    COUNT(AR.CUSTOMERCENTER ||'p'||ar.CUSTOMERID) OVER (partition BY AR.CUSTOMERCENTER ||'p'||ar.CUSTOMERID ORDER BY AR.CUSTOMERCENTER ||'p'||ar.CUSTOMERID ) AS "Entries",
    AR.CUSTOMERCENTER ||'p'||ar.CUSTOMERID                                                                                                                    AS "Member ID",
    p.FULLNAME                                                                                                                                                AS "Member Name",
    art.TEXT                                                                                                                                                  AS "Product Name",
    art.AMOUNT                                                                                                                                                AS "Amount",
    longtodate(art.ENTRY_TIME)                                                                                                                        AS "Entry Time"
FROM
    persons p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND AR_TYPE = 4
JOIN
    AR_TRANS art
ON
    art.center = ar.center
    AND art.id = ar.id
WHERE
    p.center in (:scope)
    AND art.TEXT in (:Text)
    AND (art.ENTRY_TIME BETWEEN :StartTime AND :Endtime)
    ORDER BY
    "Entries" DESC