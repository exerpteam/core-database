-- This is the version from 2026-02-05
--  
select
je.PERSON_CENTER ||'p'|| je.PERSON_ID AS person_id,
je.NAME as subject,
TO_CHAR(longtodate(je.CREATION_TIME), 'dd-MM-YYYY HH24:MI') AS creation_date
        FROM
            JOURNALENTRIES je
        WHERE
            je.NAME = '[ERROR] Invoice payment'
            AND je.CREATION_TIME BETWEEN :fromDate AND :toDate
ORDER BY
person_id,
creation_date