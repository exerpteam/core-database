SELECT
    p.external_id,
	oldID.txtvalue AS "LegacyID",
    p.firstname,
    p.lastname,
    p.sex,
    p.birthdate,
    pea2.txtvalue AS eMAIL
    
FROM
    fernwood.persons p
LEFT JOIN
        fernwood.person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
LEFT JOIN
        fernwood.person_ext_attrs pea2
                ON pea2.personcenter = p.center
                AND pea2.personid = p.id
                AND pea2.name = '_eClub_Email'
LEFT JOIN 
        fernwood.person_ext_attrs oldID
        ON oldID.personcenter = p.center
        AND oldID.personid = p.id   
        AND oldID.name = '_eClub_OldSystemPersonId'  
WHERE
    p.STATUS IN (1,3)
AND p.persontype != 2
AND p.center IN (:Scope)
AND pea.txtvalue IS NULL

UNION

SELECT DISTINCT
    p.external_id,
    oldID.txtvalue AS "LegacyID",
    p.firstname,
    p.lastname,
    p.sex,
    p.birthdate,
    pea2.txtvalue AS eMAIL

FROM
    fernwood.persons p
JOIN
    fernwood.clipcards c
ON
    c.owner_center = p.center
AND c.owner_id = p.id
LEFT JOIN
    fernwood.person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
LEFT JOIN
        fernwood.person_ext_attrs pea2
                ON pea2.personcenter = p.center
                AND pea2.personid = p.id
                AND pea2.name = '_eClub_Email'
LEFT JOIN 
        fernwood.person_ext_attrs oldID
        ON oldID.personcenter = p.center
        AND oldID.personid = p.id   
        AND oldID.name = '_eClub_OldSystemPersonId'
WHERE
    c.clips_left > 0
AND c.finished = false
AND c.cancelled = false
AND c.blocked = false
AND p.status IN (0,1,2,3,6,9)
AND p.persontype != 2
AND p.center IN (:Scope)
AND pea.txtvalue IS NULL

UNION

SELECT DISTINCT
    p.external_id,
    oldID.txtvalue AS "LegacyID",
    p.firstname,
    p.lastname,
    p.sex,
    p.birthdate,
    pea2.txtvalue AS eMAIL

FROM
    fernwood.persons p
JOIN
    fernwood.subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
LEFT JOIN
    fernwood.person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
LEFT JOIN
        fernwood.person_ext_attrs pea2
                ON pea2.personcenter = p.center
                AND pea2.personid = p.id
                AND pea2.name = '_eClub_Email'
LEFT JOIN 
        fernwood.person_ext_attrs oldID
        ON oldID.personcenter = p.center
        AND oldID.personid = p.id   
        AND oldID.name = '_eClub_OldSystemPersonId'
WHERE
    s.start_date > CURRENT_DATE
AND p.center IN (:Scope)
AND p.persontype != 2
AND pea.txtvalue IS NULL