-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4129
SELECT
    p.CENTER || 'p' || p.ID                      AS "Memberid",
    bi_decode_field('PERSONS','STATUS',p.STATUS) AS "PersonStatus",
    ar.BALANCE                                   AS "Amount",
    (
        CASE ar.STATE
            WHEN 0
            THEN 'Active'
            WHEN 1
            THEN 'Blocked'
            WHEN 2
            THEN 'Transferred, not collected'
            WHEN 3
            THEN 'Transferred, collected'
            WHEN 4
            THEN 'Deleted'
            ELSE 'Unknown'
        END) AS "DebtAccountState"
FROM
    FW.PERSONS p
JOIN
    FW.ACCOUNT_RECEIVABLES ar
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID
WHERE
    ar.AR_TYPE = 5
    AND ar.BALANCE != 0 
	AND
	(
		(
			:balance = 'Positive' 
			AND 
			ar.BALANCE > 0
		)
		OR
		(
			:balance = 'Negative' 
			AND 
			ar.BALANCE < 0
		)		 
	)