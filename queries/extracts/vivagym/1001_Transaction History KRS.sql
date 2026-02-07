SELECT * 
FROM
	transactionhistory_krs
WHERE
	trim(personId) in (:KRS_ID)