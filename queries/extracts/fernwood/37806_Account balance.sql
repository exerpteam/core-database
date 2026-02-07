SELECT
        p.center||'p'||p.id as personid,
        ar.balance                        
FROM account_receivables ar
JOIN persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
WHERE
        p.center||'p'||p.id IN (:personID)
		AND
		ar.ar_type = 4