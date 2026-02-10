-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pea.personcenter AS "Member Center",
        CAST(pea.personid AS TEXT) AS "Member ID",
        pea.name AS "Category",
        pea.txtvalue AS "Text",
        TO_CHAR(longtodateC(pea.last_edit_time, pea.personcenter), 'dd-MM-YYYY') AS "Latest Change"
FROM person_ext_attrs pea
WHERE
        (pea.personcenter,pea.personid) IN (:memberid)