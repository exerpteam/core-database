-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
                 e.*
         FROM ENTITYIDENTIFIERS e
         LEFT JOIN PERSONS p
                 ON p.CENTER = e.REF_CENTER AND p.ID = e.REF_ID
         WHERE
                 e.REF_TYPE = 1 -- PERSONS
                 AND p.CENTER IS NULL -- NO PERSON LINKED TO IT
                 AND  e.IDMETHOD =5 -- PIN
                 AND e.ENTITYSTATUS = 1 -- OK
                 AND e.REF_CENTER = 998 -- FAKE CLUB THAT NEVER EXISTED
                 AND e.ASSIGN_EMPLOYEE_CENTER = 100
                 AND e.ASSIGN_EMPLOYEE_ID = 1
