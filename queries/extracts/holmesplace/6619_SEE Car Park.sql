
SELECT
    p.center || 'p' || p.id AS PersonId,
    p.FIRSTNAME,
    p.lastname,
    ei.IDENTITY,
    CASE p.status
       WHEN 1 THEN 'Active'
       WHEN 3 THEN 'TempInactive'
       ELSE 'Inactive'
    END
FROM
    HP.PERSONS p
JOIN
    HP.ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.center
AND ei.REF_ID = p.id
AND ei.REF_TYPE = 1
WHERE
    p.status IN (0,1,2,3,6,9)
AND ei.ENTITYSTATUS = 1
AND ei.IDMETHOD = 4
AND p.center IN (1)