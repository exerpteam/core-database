SELECT
	bank_regno,
	bank_branch_no,
	bank_accno,
	COUNT(center) AS NumberOfPaymentAgreements

FROM payment_agreements 
GROUP BY
	bank_regno,
	bank_branch_no,
	bank_accno
	--bank_account_holder

HAVING COUNT(center)>5

ORDER BY COUNT(center) DESC
