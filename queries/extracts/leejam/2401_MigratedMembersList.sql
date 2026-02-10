-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    cp.center || 'p' ||cp.id AS personId,
    pea.txtvalue             AS LegacyMemberId,
    cp.external_id,
    cp.fullname,
    CASE cp.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS PersonStatus,
    CASE
        WHEN cp.sex = 'C'
        THEN 'YES'
        ELSE 'NO'
    END AS IS_COMPANY,
	TO_CHAR(longtodatec(je.creation_time, je.person_center), 'dd-MM-yyyy HH24:MI') AS MigratedDate
FROM
    person_ext_attrs pea
JOIN
    persons p
ON
    p.center = pea.personcenter
    AND p.id = pea.personid
JOIN
   journalentries je
ON
   je.person_center = p.center
   AND je.person_id = p.id
   AND je.name = 'Person created' 	
JOIN
    persons cp
ON
    cp.center = p.current_person_center
    AND cp.id = p.current_person_id
WHERE
    pea.personcenter IN ($$Scope$$)
    AND pea.name='_eClub_OldSystemPersonId'
    AND pea.txtvalue IS NOT NULL
