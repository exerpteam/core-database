-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                dateToLongC(getCenterTime(c.id), c.id) AS today,
                c.id AS center_id
        FROM
                centers c
)
SELECT
    ca.center || 'p'|| ca.id || 'rpt' || ca.subid AS "Id",
    pg.privilege_set AS "PrivilegeSet"
FROM companyagreements ca
JOIN params par
        ON par.center_id = ca.center
JOIN privilege_grants pg
        ON pg.granter_center = ca.center
        AND pg.granter_id = ca.id
        AND pg.granter_subid = ca.subid
        AND pg.granter_service = 'CompanyAgreement'
WHERE
        ca.state = 1
        AND pg.valid_to IS NULL
        OR pg.valid_to > today
        