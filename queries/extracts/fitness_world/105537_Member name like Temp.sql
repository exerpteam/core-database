-- This is the version from 2026-02-05
--  
SELECT per.center|| 'p'|| per.id     AS member,
       per.external_id AS External_ID,
       CASE per.persontype
         WHEN 0 THEN 'Private'
         WHEN 1 THEN 'Student'
         WHEN 2 THEN 'Staff'
         WHEN 3 THEN 'Friend'
         WHEN 4 THEN 'Corporate'
         WHEN 5 THEN 'Onemancorporate'
         WHEN 6 THEN 'Family'
         WHEN 7 THEN 'Senior'
         WHEN 8 THEN 'Guest'
         WHEN 9 THEN 'Child'
         WHEN 10 THEN 'External_Staff'
         ELSE 'Unknown'
       END           AS "Person Type",
       CASE per.status
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
       END           AS STATUS,
       per.fullname,
       To_date(pea.txtvalue, 'YYYY-MM-DD')
FROM   persons per
       LEFT JOIN person_ext_attrs pea
              ON per.center = pea.personcenter
                 AND per.id = pea.personid
                 AND pea.NAME = 'CREATION_DATE'
WHERE  firstname like '%test%'