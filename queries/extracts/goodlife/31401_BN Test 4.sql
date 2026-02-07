SELECT
r.center||'p'||r.id AS family_id
,r.relativecenter||'p'||r.relativeid AS primary_id
,r2.relativecenter||'p'||r2.relativeid AS company_id
FROM
relatives r
JOIN relatives r2 USING (center,id)
JOIN PERSON_EXT_ATTRS px
ON px.personcenter = r2.relativecenter
AND px.personid = r2.relativeid
AND px.name = 'COMPANYTYPE'
AND px.txtvalue = 'CERT'
WHERE
r.status != 3
AND r.rtype = 16 -- Family of Employee
AND r2.rtype = 3 -- Company Agreement
AND r2.status != 3
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
AND NOT EXISTS(
    SELECT
    1
    FROM
    relatives r3
    WHERE
    (
        (
            r.center = r3.center
            AND r.id = r3.id
        ) OR (
            r.center = r3.relativecenter
            AND r.id = r3.relativeid
        )
    )
    AND r3.rtype IN (4,5,1) -- Family, Friend, Friend of Employee
    AND r3.status != 3
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