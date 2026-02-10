-- The extract is extracted from Exerp on 2026-02-08
-- This is a temporary extract that returns the number of payment agreements (active and inactive) that contains the same banking information.
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
