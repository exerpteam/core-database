SELECT
r.center||'p'||r.id AS primary_id
,r.relativecenter||'p'||r.relativeid AS company_id
FROM
relatives r
JOIN PERSON_EXT_ATTRS px
ON px.personcenter = r.relativecenter
AND px.personid = r.relativeid
AND px.name = 'COMPANYTYPE'
AND px.txtvalue = 'CERT'

JOIN persons p
ON p.center = r.center
AND p.id = r.id
AND p.status = 2 -- Inactive
    -- Will inadvertently filter out leads in the middle of the sales process, and/or anyone with a subscription

WHERE
r.status != 3
AND r.rtype = 3 -- Company Agreement
AND NOT EXISTS(
    SELECT 1 FROM relatives r2
    JOIN subscriptions s
    ON s.owner_center = r2.center
    AND s.owner_id = r2.id
    AND s.state IN (2,4,8)
    WHERE
    r.center = r2.relativecenter
    AND r.id = r2.relativeid
    AND r2.rtype IN (4,5,1,16) -- Family, Friend, Friend of Employee, Family of Employee
    AND r2.status != 3
)
AND NOT EXISTS (
    SELECT
    1
    FROM
    subscriptions s
    WHERE
    s.owner_center = r.center
    AND s.owner_id = r.id
    AND s.state IN (2,4,8)
)
AND NOT EXISTS (
    SELECT
    1
    FROM
    person_ext_attrs px
    WHERE
    px.personcenter = r.center
    AND px.personid = r.id
    AND px.name = 'APISaleRequiresIntervention'
    AND px.txtvalue = '1'
)

ORDER BY 2
LIMIT 1500