-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "member_id",
    ar.BALANCE                            AS "debt account balance", 
	CASE P.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 
        'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARY 
        INACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' 
        WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 
        'ANONIMIZED' WHEN 9 THEN 'CONTACT' ELSE 'UNKNOWN' END AS 
        STATUS
FROM
    FW.ACCOUNT_RECEIVABLES ar

	JOIN fw.persons p ON 
	p.center = ar.CUSTOMERCENTER
	AND p.ID = ar.CUSTOMERID
WHERE
    ar.AR_TYPE = 5
    and ar.BALANCE in (-100,-200)
    and ar.CENTER in (:scope)
	and ar.BALANCE < 0