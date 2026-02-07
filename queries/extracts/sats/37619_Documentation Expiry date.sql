SELECT
    r.CENTER ||'p'|| r.ID AS "Member ID Number",
    DECODE ( RTYPE, 0,'Noll', 1,'Friend', 2, 'Två', 3,'Company Agreement', 4,'Family', 5,'Fem', 6,'Sex') AS "Type of Relation",
    r.RELATIVECENTER ||'p'|| r.RELATIVEID AS "ID Number of Relation",
    DECODE (r.status,0, 'Lead', 1, 'Active', 2,'Inactive', 3, 'Blocked', 'unkown') as "Documentation Status",
    r.EXPIREDATE as "Documentation Expiry Date"
FROM
    SATS.RELATIVES r
JOIN
    persons p
ON
    r.CENTER = p.CENTER
    AND r.ID = p.ID
WHERE
    r.EXPIREDATE >= :EarliestExpiryDate
    AND r.EXPIREDATE <= :LatestExpiryDate
    --and    r.RTYPE =1
--and r.EXPIREDATE is not null    
AND p.status IN (1,
                     3)