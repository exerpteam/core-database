WITH params AS MATERIALIZED (
	SELECT
		dateToLongC(getCenterTime(c.id), c.id) AS today,
		c.id AS center_id
	FROM
		centers c
),
globalRounding AS (
	SELECT
		sys.*,
		sys.txtvalue AS rounding
	FROM
		systemproperties SYS
	WHERE
		sys.globalid = 'FINANCE_ROUND'
		AND sys.scope_type = 'A'
		AND sys.scope_id = 2
)
SELECT
	ca.center || 'p' || ca.id || 'rpt' || ca.subid AS "Id",
	pg.privilege_set AS "PrivilegeSet",
	pg.sponsorship_name AS "SponsorshipName",
	pg.sponsorship_amount::FLOAT(4) AS "SponsorshipAmount",
	CASE
		WHEN pg.sponsorship_rounding IS NULL THEN globalRounding.rounding
		ELSE pg.sponsorship_rounding
	END AS "SponsorshipRounding"
FROM
	companyagreements ca
JOIN
	params par ON par.center_id = ca.center
JOIN
	privilege_grants pg ON pg.granter_center = ca.center
	AND pg.granter_id = ca.id
	AND pg.granter_subid = ca.subid
	AND pg.granter_service = 'CompanyAgreement'
CROSS JOIN
    globalRounding globalRounding
WHERE
	ca.state = 1
	AND pg.valid_to IS NULL
	OR pg.valid_to > today