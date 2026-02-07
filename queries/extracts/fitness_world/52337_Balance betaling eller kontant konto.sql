-- This is the version from 2026-02-05
--  
SELECT
    ar.customercenter || 'p' || ar.customerid AS memberid,
    p.firstname,
    p.lastname,
    p.status,
    ar.balance,
    CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        ELSE 'UNKNOWN'
    END AS status_text
FROM account_receivables ar
JOIN persons p
    ON ar.customercenter = p.center
   AND ar.customerid = p.id
WHERE ar.ar_type = :Kontotype
  AND ar.balance > :MoreThan
  AND ar.balance < :LessThan
  AND ar.customercenter IN (:Scope)
  AND p.status IN (0, 2, 6);
