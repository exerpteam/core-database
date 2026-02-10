-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center||'p'||p.id AS "Member ID",
je.name,
je.text,
je.creatorcenter ||'emp'|| je.creatorid AS "Staff"
FROM persons p
JOIN journalentries je ON je.person_center = p.center AND je.person_id = p.id
WHERE
        p.center IN (:Scope)
        AND je.creatorcenter = 6999
        AND je.creatorid = 1
        AND je.name = 'EFT subscription termination'
AND je.CREATION_TIME BETWEEN :fromDate AND :toDate
GROUP BY
p.center,
p.id,
je.name,
je.text,
je.creatorcenter,
je.creatorid