-- This is the version from 2026-02-05
--  
SELECT
pea.personcenter AS "Medlem Center",
pea.personid::varchar(20) AS "Medlem ID",
pea.name AS "Kategori",
pea.txtvalue AS "Tekst",
TO_CHAR(longtodateC(pea.last_edit_time, pea.personcenter), 'dd-MM-YYYY') AS "Seneste ændring"
FROM
person_ext_attrs pea
WHERE
pea.personcenter ||'p'|| pea.personid IN (:memberid)
AND pea.NAME = 'TRANSFERMEMBER'
AND pea.TXTVALUE is not null