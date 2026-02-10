-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT * 
FROM
	transactionhistory_krs
WHERE
	trim(personId) in (:KRS_ID)