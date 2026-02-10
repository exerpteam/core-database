-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER||'p'||p.id AS EXERP_PERSON_ID,
    ext.txtvalue AS CARE_ID
FROM
    goodlife.persons p
JOIN
    goodlife.person_ext_attrs ext
ON
    p.center = ext.personcenter
AND p.id = ext.personid
AND ext.name = '_eClub_OldSystemPersonId'

where p.center in (:scope)

