-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,
                         700,730,
                         733,728,762,783,782,737,743,7084,725)
    )
SELECT
    je.PERSON_CENTER || 'p' || je.PERSON_ID AS PersonId,
    longtodate(je.CREATION_TIME)            AS CreationDate,
    creator.fullname                        AS CreatorName,
    je.NAME                                 AS Header,
    encode(je.BIG_TEXT,'escape')            AS Text
FROM
    plist p
JOIN
    JOURNALENTRIES je
ON
    je.PERSON_CENTER = p.Center
AND je.PERSON_ID = p.Id
AND je.JETYPE = 3
AND je.CREATORCENTER IS NOT NULL
    --AND (je.CREATORCENTER || 'emp' || je.CREATORID) NOT IN ('100emp12141')
AND je.NAME != 'Person created'
AND je.CREATION_TIME > 1478505900000
JOIN
    employees emp
ON
    emp.center = je.CREATORCENTER
AND emp.id = je.CREATORID
JOIN
    persons creator
ON
    creator.center=emp.personcenter
AND creator.id = emp.personid