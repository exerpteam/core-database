-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "member_id",
    ar.BALANCE                            AS "debt account balance"
FROM
    FW.ACCOUNT_RECEIVABLES ar
WHERE
    ar.AR_TYPE = 5
    and ar.BALANCE in (-100,-200)
    and ar.CENTER in (:scope)
	and ar.BALANCE < 0